{ pkgs, config, ... }:
let
  home = config.home.homeDirectory;

  excludes = builtins.toFile "restic-excludes" ''
    .dropbox-dist
    Dropbox/
    target/
  '';

  cron = { name, calendar, command, randomDelay ? 60 * 60 }: {
    services."${name}" = {
      Service = {
        Type = "oneshot";
        Environment = [
          "RESTIC_REPOSITORY=/mnt/backup/tera.restic"
          "RESTIC_PASSWORD_FILE=${home}/.secrets/restic-password"
        ];
        ExecStart = builtins.concatStringsSep " " command;
        Nice = 10;
      };
    };
    timers."${name}" = {
      Timer = {
        OnCalendar = calendar;
        Persistent = true;
        # Randomize start time
        RandomizedDelaySec = randomDelay;
        # Always use the same random delay
        FixedRandomDelay = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

in
{
  home.packages = [ pkgs.restic ];

  systemd.user = pkgs.lib.recursiveUpdate
    (cron {
      name = "restic-backup";
      calendar = "hourly";
      command = [
        "${pkgs.restic}/bin/restic backup"
        "--compression=max"
        "--exclude-file=${excludes}"
        "--no-scan"
        "--one-file-system"
        "--verbose"
        "${home}"
      ];
    })
    (cron {
      name = "restic-cleanup";
      calendar = "*-*-* 12:30:00";
      command = [
        "${pkgs.restic}/bin/restic forget"
        "--keep-hourly=24"
        "--keep-daily=7"
        "--keep-weekly=4"
        "--keep-monthly=12"
        "--keep-yearly=2"
      ];
    });

}

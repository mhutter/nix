{ pkgs, config, ... }:
let
  home = config.home.homeDirectory;

  excludes = builtins.toFile "restic-excludes" ''
    .dropbox-dist
    Dropbox/
    target/
    node_modules/
    .cache/sccache/
  '';

  mountPoint = "/mnt/restic";
  mountUnit = "mount-mnt-restic";
  resticRepo = "${mountPoint}/tera.restic";

  cron = { name, calendar, command, randomDelay ? 60 * 60 }: {
    services."${name}" = {
      Unit = {
        Requires = [ "${mountUnit}.service" ];
        After = [ "${mountUnit}.service" ];
      };
      Service = {
        Type = "oneshot";
        Environment = [
          "RESTIC_REPOSITORY=${resticRepo}"
          "RESTIC_PASSWORD_FILE=${home}/.secrets/restic-password"
        ];
        ExecStart = builtins.concatStringsSep " " command;
        Nice = 19;
        IOSchedulingPriority = 7;
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

  resticJobs = pkgs.lib.recursiveUpdate
    (cron {
      name = "restic-backup";
      calendar = "hourly";
      command = [
        "${pkgs.restic}/bin/restic backup"
        "--compression=max"
        "--exclude-file=${excludes}"
        "--exclude-caches"
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

in
{
  home.packages = [ pkgs.restic ];

  systemd.user = pkgs.lib.recursiveUpdate resticJobs {
    services.${mountUnit}.Service = {
      ExecStart = "/bin/sh -c 'test -d ${resticRepo} || /bin/mount ${mountPoint}'";
      ExecStop = "/bin/umount ${mountPoint}";
      RemainAfterExit = "yes";
    };
  };
}

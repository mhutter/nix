{ pkgs, config, ... }:
let
  home = config.home.homeDirectory;
  excludes = builtins.toFile "restic-excludes" ''
    .dropbox-dist
    Dropbox/
    target/
  '';
in
{
  home.packages = [ pkgs.restic ];

  systemd.user.services."restic-backup" = {
    Unit = {
      Description = "Restic backup";
    };
    Service = {
      Type = "oneshot";
      Environment = [
        "RESTIC_REPOSITORY=/mnt/backup/tera.restic"
        "RESTIC_PASSWORD_FILE=${home}/.secrets/restic-password"
      ];
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.restic}/bin/restic backup"
        "--verbose"
        "--no-scan"
        "--compression=max"
        "${home}"
        "--tag=home"
        "--tag=tera"
        "--exclude-file=${excludes}"
      ];
      Nice = 10;
    };
  };
  systemd.user.timers."restic-backup" = {
    Unit = {
      Description = "Regular restic backup";
    };
    Timer = {
      OnCalendar = "hourly";
      Unit = "restic-backup.service";
      Persistent = true;
      # Randomize start time
      RandomizedDelaySec = 60 * 60;
      # Always use the same random delay
      FixedRandomDelay = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}

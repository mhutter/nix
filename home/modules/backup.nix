{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.backup;
  home = config.home.homeDirectory;

  excludes = builtins.toFile "restic-excludes" ''
    .dropbox-dist
    Dropbox/
    safe/media/
    target/
    node_modules/
    .cache/
    .local/share/containers/
    etc/NetworkManager/system-connections
    etc/ssh/ssh_host_ed25519_key
    etc/ssh/ssh_host_rsa_key
    var/db/sudo
    var/lib/AccountsService
    var/lib/bluetooth
    var/lib/cups
    var/lib/docker
    var/lib/libvirt
    var/log
  '';

  resticRepo = "s3://s3.eu-central-003.backblazeb2.com/mhu-restic-${cfg.hostname}";
  credentialsFile = "${home}/.secrets/restic-bucket";

  cron =
    {
      name,
      calendar,
      command,
      randomDelay ? 60 * 60,
    }:
    {
      services."${name}" = {
        Unit = {
          OnFailure = [ "restic-failure-notify@%n.service" ];
        };
        Service = {
          Type = "oneshot";
          EnvironmentFile = credentialsFile;
          Environment = [
            "RESTIC_REPOSITORY=${resticRepo}"
            "RESTIC_PASSWORD_FILE=${home}/.secrets/restic-password"
          ];
          # Remove stale locks left behind by interrupted runs
          ExecStartPre = "${pkgs.restic}/bin/restic unlock";
          # --retry-lock: wait instead of failing when another job holds the lock
          ExecStart = builtins.concatStringsSep " " (command ++ [ "--retry-lock=15m" ]);
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

  resticJobs =
    lib.foldl' lib.recursiveUpdate
      {
        # Desktop notification when any restic job fails
        services."restic-failure-notify@" = {
          Unit = {
            Description = "Notify about failed restic job (%i)";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.libnotify}/bin/notify-send --urgency=critical 'Backup failed' 'Unit %i failed. Logs: journalctl --user -u %i'";
          };
        };
      }
      [
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
            "/nix/persist"
          ];
        })
        (cron {
          name = "restic-cleanup";
          calendar = "*-*-* 12:30:00";
          command = [
            "${pkgs.restic}/bin/restic forget"
            "--prune"
            "--keep-hourly=24"
            "--keep-daily=7"
            "--keep-weekly=4"
            "--keep-monthly=12"
            "--keep-yearly=10"
          ];
        })
        (cron {
          name = "restic-check";
          calendar = "Sat *-*-* 13:00:00";
          command = [ "${pkgs.restic}/bin/restic check" ];
        })
      ];

in
{
  options.backup = {
    hostname = lib.mkOption {
      description = "System Hostname";
      type = lib.types.str;
    };
  };

  config = {
    home.packages = [
      pkgs.restic
      (pkgs.writeShellScriptBin "restic-${cfg.hostname}" ''
        export RESTIC_REPOSITORY=${resticRepo}
        export RESTIC_PASSWORD_FILE=${home}/.secrets/restic-password
        eval "$(sed 's/^/export /' ${credentialsFile})"
        exec restic $@
      '')
    ];

    systemd.user = resticJobs;
  };
}

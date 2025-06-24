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
    var/lib/tailscale
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
        Service = {
          Type = "oneshot";
          EnvironmentFile = credentialsFile;
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

  resticJobs =
    pkgs.lib.recursiveUpdate
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
          "--keep-hourly=24"
          "--keep-daily=7"
          "--keep-weekly=4"
          "--keep-monthly=12"
          "--keep-yearly=10"
        ];
      });

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

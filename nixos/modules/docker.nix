{
  pkgs,
  username,
  secrets,
  ...
}:

{
  users.users.${username}.extraGroups = [ "docker" ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      debug = true;
      log-level = "debug";
      registry-mirrors = [ secrets.dockerRegistryMirror ];
    };
  };

  # Enable the common /etc/containers configuration module
  # NOTE: This currently generates a v1 format of the
  # /etc/containers/registries.conf file, which is no longer supported by
  # skopeo. Hence we hand-write the config files for now.
  virtualisation.containers.enable = false;
  # policy.json must exist for skopeo to work.
  environment.etc."containers/policy.json".source = "${pkgs.skopeo.policy}/default-policy.json";
}

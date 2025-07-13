{ username, secrets, ... }:

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
}

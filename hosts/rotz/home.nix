{ pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/modules/backup.nix
  ];

  backup.hostname = "rotz";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  programs = {
    btop.settings.disks_filter = "/ /nix /boot";
    zsh.history.path = "/nix/persist/home/mh/.zsh_history";
  };

  # apt-dater configuration
  home.file.".config/apt-dater/apt-dater.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE apt-dater SYSTEM "file://${pkgs.apt-dater}/share/xml/schema/apt-dater/apt-dater.dtd">
    <apt-dater xmlns:xi="http://www.w3.org/2001/XInclude">
        <!-- SSH(1) options -->
        <ssh
    	    cmd="${pkgs.openssh}/bin/ssh"
    	    opt-cmd-flags="-t"
    	    sftp-cmd="${pkgs.openssh}/bin/sftp"
    	    spawn-agent="true">
    	    <add-key fn="/home/mh/.ssh/id_ed25519" />
        </ssh>
        <!-- Path to hosts file and status directory. -->
        <paths hosts-file="hosts.xml"/>
    </apt-dater>
  '';

  home.file.".config/apt-dater/hosts.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE hosts SYSTEM "file://${pkgs.apt-dater}/share/xml/schema/apt-dater/hosts.dtd">
    <hosts xmlns:xi="http://www.w3.org/2001/XInclude">
      <xi:include href="/home/mh/code/mhnet/out/hosts.xml" xpointer="xpointer(/hosts/*)">
        <xi:fallback />
      </xi:include>
    </hosts>
  '';
}

rec {
  user = {
    name = "";
    email = "";
    workEmail = "";
    hashedPassword = "";
  };

  rbw-settings = {
    base_url = "";
    email = user.email;
  };

  sshHosts = { };
  customCACertificates = [ ];
}

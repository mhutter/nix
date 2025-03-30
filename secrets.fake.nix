rec {
  user = {
    name = "";
    email = "";
    hashedPassword = "";
  };

  rbw-settings = {
    base_url = "";
    email = user.email;
  };

  sshHosts = { };
}

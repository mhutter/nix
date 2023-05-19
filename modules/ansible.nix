{ pkgs, ... }:

{
  home.packages = [ pkgs.ansible ];
  home.file.".ansible.cfg".text = ''
    [defaults]
    forks = 20
    inventory = ~/.ansible/sshop_inventory

    # Allow displaying and gathering custom stats
    show_custom_stats = True
    callbacks_enabled = profile_tasks

    ### Speed up fact gathering
    # Don't gather facts on each role (can be overwritten in playbooks)
    gathering = smart
    # Don't gather Puppet or Chef facts
    gather_subset = all,!facter,!ohai
    # Cache facts
    fact_caching = jsonfile
    fact_caching_connection = .ansible/facts
    fact_caching_timeout = 600

    # Disable useless features
    nocows = True
    retry_files_enabled = False

    [inventory]
    unparsed_is_failed = True

    [privilege_escalation]
    become = True

    [ssh_connection]
    ssh_args = -o ControlMaster=auto -o ControlPersist=600s
    control_path = %(directory)s/ssh-%%C
    control_path_dir = ~/.ansible/cp
    pipelining = True
    scp_if_ssh =  True
  '';
}

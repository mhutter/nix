# HomeManager configs

## DONE

### Make auto-completions work out of the box

<details>
<summary>
It did work out of the box; the reason it did NOT work was because ZSH was smart enough to recognize that `kubectl` was linked to `kubecolor`, and tried ITS completions (which do not exist).

Solution:

    compdef kubecolor=kubectl

</summary>

Currently, completions from "unmanaged" packages do not work out of the box.

The `kubectl` package for example contains `share/zsh/site-functions/_kubectl`, but this is not linked or added to `$fpath`.

[Setting up zsh completions for tools installed via home-manager](https://knezevic.ch/posts/zsh-completion-for-tools-installed-via-home-manager/) describes how to locate & copy all completion files in a separate folder, but I was not yet able to work out how this works using Home Manager.

[The documentation](https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enableCompletion) says to add `environment.pathsToLink = [ "/share/zsh" ];` to "your system configuration", but since I don't use NixOS, how can I achieve this?


`fd`ing through `/nix`, I found out that the `_kubectl` (and other) file is indeed copied into the current `home-manager-path` module (`/nix/store/wrnxc15nj5snc6cjq5rl49d332b1hl61-home-manager-path/share`), which is linked as `~/.nix-profile/share`, which in turn is in `$fpath` (but it still doesn't work)

</details>


## Further reading

* https://github.com/maxbrunet/dotfiles
* https://github.com/sherubthakur/dotfiles

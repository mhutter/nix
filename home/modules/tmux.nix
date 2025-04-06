{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;

    # increase scrollback lines
    historyLimit = 100000;

    # Improve colors
    terminal = "screen-256color";

    # Start window numbers at 1 and make pane numbering consistent with windows
    baseIndex = 1;

    extraConfig = ''
      # renumber windows when a window is closed
      set -g renumber-windows on

      # Automatically set window titles
      setw -g automatic-rename on
      set -g set-titles on

      # Status Bar
      set -g status-interval 1
      set -g status-left ""
      set -g status-right '%T %F'
      setw -g window-status-current-style fg=blue
      set -g status-fg white
      set -g status-bg black

      # Notifications
      setw -g monitor-activity on
      set -g visual-activity on

      # Input & Controls
      set -g mouse off
      setw -g mode-keys vi
      set -sg escape-time 0

      # Use Ctrl-vim keys without prefix key to switch panes
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      # Resize panes
      bind-key J resize-pane -D 5
      bind-key K resize-pane -U 5
      bind-key H resize-pane -L 5
      bind-key L resize-pane -R 5

      # Reload tmux config
      bind r source-file ~/.config/tmux/tmux.conf

      # Open new panes in the same path
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}

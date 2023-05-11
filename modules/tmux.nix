{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    # increase scrollback lines
    historyLimit = 100000;
    # Improve colors
    terminal = "screen-256color";

    extraConfig = ''
      # start window numbers at 1 and make pane numbering consistent with windows
      set -g base-index 1
      set-window-option -g pane-base-index 1

      # renumber windows when a window is closed
      set -g renumber-windows on

      # Automatically set window titles
      set-window-option -g automatic-rename on
      set-option -g set-titles on

      # Status Bar
      set-option -g status-interval 1
      set-option -g status-left ""
      set-option -g status-right '%T %F'
      set-window-option -g window-status-current-style fg=blue
      set-option -g status-fg white
      set-option -g status-bg black

      # Notifications
      setw -g monitor-activity on
      set -g visual-activity on

      # Input & Controls
      set-option -g mouse off
      #set-option -g mouse-select-window on
      #set-option -g mouse-select-pane on
      #set-option -g mouse-resize-pane on
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


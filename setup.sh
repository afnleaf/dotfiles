#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sf "$DOTFILES/alacritty"    "$HOME/.config/alacritty"
ln -sf "$DOTFILES/nvim"         "$HOME/.config/nvim"
ln -sf "$DOTFILES/tmux.conf"    "$HOME/.tmux.conf"

echo "dotfiles symlinked."

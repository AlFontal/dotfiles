# dotfiles
# dotfiles

## Setup on a new Mac

Each config lives here and is symlinked into place.

```sh
ln -s ~/projects/dotfiles/tmux/tmux.conf ~/.tmux.conf
mkdir -p ~/.config/ghostty
ln -s ~/projects/dotfiles/ghostty/config.ghostty ~/.config/ghostty/config.ghostty

# Hammerspoon: window divider (⌘⌥←/→) and directional focus (⌃⌥←/→)
brew install --cask hammerspoon
mkdir -p ~/.hammerspoon
ln -s ~/projects/dotfiles/hammerspoon/init.lua ~/.hammerspoon/init.lua
# then allow Hammerspoon in System Settings → Privacy & Security → Accessibility

# Rectangle: settings are stored in macOS preferences, so import the export
brew install --cask rectangle
osascript -e 'quit app "Rectangle"'
defaults import com.knollsoft.Rectangle ~/projects/dotfiles/rectangle/com.knollsoft.Rectangle.plist
open -a Rectangle
```

After changing Rectangle settings, refresh the export:

```sh
defaults export com.knollsoft.Rectangle - | plutil -convert xml1 -o ~/projects/dotfiles/rectangle/com.knollsoft.Rectangle.plist -
```

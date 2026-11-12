# dotfiles

My macOS configuration files, kept in one place so I can set up a new machine
quickly and track changes over time.

| Folder | What it configures |
|---|---|
| `ghostty/` | Ghostty terminal: font, theme, window appearance, keyboard behaviour and the quick terminal |
| `tmux/` | tmux, with mouse support turned on |
| `hammerspoon/` | Window shortcuts: ⌘⌥←/→ moves the divider between two side-by-side windows, resizing both; ⌃⌥←/→ focuses the window to the left or right |
| `rectangle/` | Rectangle window snapping shortcuts (halves, maximize, move between displays) |

## Setup on a new Mac

Each config except Rectangle's lives here and is symlinked into place, so edits
to the live config show up in this repo.

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

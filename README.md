# ge-wayland-steam-overlay-ext

This repository is used to package
[GloriousEggroll](https://github.com/GloriousEggroll)'s Wayland support for
the Steam overlay from
[proton-ge-custom](https://github.com/GloriousEggroll/proton-ge-custom), so it
can be used in Proton with Wine's Wayland driver, with some custom changes on top.

Imported from proton-ge-custom commit
[87429b0f](https://github.com/GloriousEggroll/proton-ge-custom/commit/87429b0f):

- `layer/` comes from `vklayers/steam-overlay-wayland`
- `bridge/` comes from `lsteamclient/overlay_bridge`

# to-do

- makefile (?)
- import changes from [nanomatters' fork](https://github.com/nanomatters/ge-steam-overlay-wayland)
- CI (import/test build? idk)
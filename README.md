# Shotwell migration script

Script for exporting the metadata about photos in a Shotwell database that can't be derived directly from the files themselves.

It exports the following things:

- The list of tags
- Photographs
    - Filename
    - Rating
    - The tags it's associated with

It does not export events, because they're not useful to me in this case. If they're useful to you, hopefully my treatment of tags can be applied to events with minimal modification.


## Purpose

Take a Shotwell database, and generate from it the output needed for importing the pictures in it into Darktable along with their metadata.

Darktable's use of Lua as a scripting language is the reason I've implemented this code in that language.


## Motivation

Shotwell appears to be a dead project; this is certainly the case from the perspective of NixOS development.

I've been using Darktable to manage photographs that I took myself, and Shotwell to manage pictures that I've downloaded or gotten from other sources. Rather than do this again, I'm merging the two and will figure out how to distinguish them.

Due to the way I've been using Shotwell, tags are useful to me but events are not, so I've simply ignored events.


## References

- [Shotwell database architecture page](https://wiki.gnome.org/Apps/Shotwell/Architecture/Database)
- [Darktable Lua documentation](https://docs.darktable.org/lua/stable/)

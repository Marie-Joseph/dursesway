# dursesway
Cursesway but in D this time.

## Overview
This is simply cursesway, but in D. This is primarily a practice project for the
nice-curses library.

## Compilation
All you need is dub and a D compiler. Information on obtaining those can be found
[on D's website](https://dlang.org/download.html). From there, simply run `dub build`
and you're off to the races.

## Controls
The controls are vim-like-ish. In the startloop, navigation is done with `hjkl`.
You can "give" life to (or take it from) a cell with `g`. Press space to begin.

While the simulation is running, you can pause with the spacebar.
While paused, you can press `r` to reset the worldspace to its original state,
or `d` to dump a file called "dway.dmp" which contains the field in it.

You can press `q` to quit at any time.

## TODO
* instruction string
* Easter egg

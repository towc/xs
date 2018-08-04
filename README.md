# xs
project setup tool for X

As humans, when we set things up, we know which keys we are pressing, and not which api magic we'd need to use to do everything from the command line

The idea here is to set up a tool that consumes the keystrokes you want in a reusable way, so you don't have to create a bash script and look at everything's man page, as you already know what you want to do

# platforms
anything that uses the X window server and the xdotool functionality

# setup
currently requires that you [install zsh](https://gist.github.com/derhuerst/12a1558a4b408b3b2b6e#installing-zsh-on-linux)

# install
clone this repo and move/copy the `xs` anywhere inside your `$PATH`

# usage
create `~/.project-setups/` and add a file after looking at [syntax](#syntax), then run `xs that-file`

# syntax
a typical config/script might look like this

```
;;;
; definitions

; tmux prefix
ft * ctrl+b

; split tmux
fs @t
fs * quotedbl

; go to next split
fn @t
fn o

; open terminal and start tmux with 2 splits
fi * super+Enter
fi . tmux
fi @s

;;;
; instructions

; super+n moves to workspace n in i3wm
* super+1
@i
. cd Projects/xs
@n
. vim
. :e xs

* super+2
@i
. mutter
@n
. cal

; open browser
* super+3
; super+d in i3wm opens a headless command executioner like rofi or dmenu
* super+d
. opera
; wait 10 seconds for it to start up
# 10
; go to address bar
* ctrl+l
. github.com/towc/xs
; open 2 new tabs
*2ctrl+t
; go to the first one
* ctrl+1
```

the first character in every line is a command, the second is a "flag" or amount (if not 1), and the rest of the line is the parameter of the command

```
*3super+Enter

cf----------
||    |
||    \- parameter
|\- flag/amount
\- command
```

here's the list of commands and their behaviour with flags
 - `.`: type the parameter and press enter
   - `..`: don't press enter this time
 - `*`: type the character specified in the parameter
 - `;`: a comment. The rest of the line is ignored
 - `f`: define a line in a macro/function. The flag is the name of the macro/function
 - `@`: call a macro/function. The flag is the name of the macro/function
 - `!`: send the parameter as notification (currently uses notify-send, and echoes)
 - `#`: sleep for the number of seconds specified in the parameter. This can be a non-integer amount
 - `z`: if there is a parameter, set the sleep time between commands to that amount of seconds. Reset if the parameter is empty
 - `+`: move cursor to `x y` specified in text
   - `+.`: and click

empty lines are skipped

Unrecognized commands make the program quit, which is useful when debugging up to a portion of it

If more than 500 commands are used, the program will also quit, as it's likely you might have gotten in an infinite loop. You can change this limit on line 3 of the xs script. It will be added as an option (or as a command/variable maybe) later

When something goes wrong, the macro history is echoed so you can see what might have gone wrong. `-` signifies exiting a macro

The macro history for the sample might look like this: `ist---nt--ist---nt--`

# plans
I originally wrote this as a script just for myself, and I happen to be using zsh with i3 on X, so the next thing to do would be port the code to something more accessible and abundant. I'm one of those mad people who enjoy JS, so I'll turn it into an npm package

Then it should either detect what notification/dotools are available (or use a config) and use those instead, so people aren't bound to notify-send, X, or even linux

At that point it would be nice to have better syntax for functions/macros, more flexible parametrization (also with functions/macros), declaring variables, importing lines from other files (maybe `> filename`) command

And some users might not usually have stuff like dmenu/rofi, so another command for executing arbitrary commands might also be neat, something like `: C:/path/to/opera.exe`

then all sorts of other flags, so you can keep keys pressed, or drag the cursor while it's pressed

# contributing
This project is in the early stages, so if you have any recommendations/requests, make an issue so we can all discuss it together

To contribute code, fork this repo, create a branch with the `fix/improvement/feature-<name>`, and submit a PR explaining what changed. Ideally make an issue before sending the PR, as you wouldn't want to write a lot of code and discover that actually this is conflicting with other possible features

# desired philosophy
These confscripts should be very easy to use, and make you more productive. I wouldn't want to add more nesting logic than macros and repeats. The second it's not naturally readable anymore, something went wrong. That said, it is currently hard-ish to read now, but I consider that to be in exchange for productivity. The syntax might get more complicated, but you should still always be able to only use the basic features without knowing much about the rest of it.

I'd like to compare it to vim: it might be slightly weird to get used to at first, but once you figure out you can use `i` to get into insert mode `esc` to get out of it, and `:wq` to write and quit, you can technically do anything. and other features are kind of just an extension of that to make you much more productive. And just like here, vim commands are still fairly cryptic, even if I'd argue still human readable

# TODO
- decide what language to use
- come up with a better name
  - short
  - available through that language/environment package manager
- create a syntax that isn't just the first thing that comes up to mind
  - multicharacter macros
  - variables
    - with substitution
    - modifying behaviour like sleep time / max commands
    - globals so you can change across multiple files
  - parameters
  - import from external files
- write better docs
- add a way to abort externally (ctrl+c maybe)
- record mode, which auto-creates a confscript file for you to modify (like vim registers for macros, something like `xs --record some-file`)
- take in files from arbitrary paths
  -  should this include over the network? If on an insecure connection, this is easily the end of you. Also, simplifies other hacking scripts a bit too much

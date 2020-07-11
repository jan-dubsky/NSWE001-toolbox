# Toolbox for `NSWE001`

## Motivation

During _embedded and real-time systems_ course, embedded board `STM32F4` is
used.  Unfortunately, setting up the environment to work with this embedded
board is not what I would call trivial.  This is the reason, why the proper
environment is already prepared on MFF computers at Malá Strana.
Nevertheless, there can be objective reasons to use your own computer.

For example:
  - Coronavirus crisis.
  - You don't want to spend long hours at school, coding embedded systems.
  - Some keyboards in the lab simply don't support typing. ☺️

To make local setup much easier, I've decided to write this simple toolbox
containing all tools you need to build, run and debug `STM32F4` board.
The only actual requirements are `shell` and `Docker`.

## Description

Whole project consists of 2 basic components. The first one is `Dockerfile`
which is used to build an image containing all build & debug dependencies.
The other one is a set of shell scripts which are used to run `Docker`
command and provide much better user experience, especially for those who
aren't used to work with `Docker`.

To be more specific about shell scripts, there are actually two of them.
The first one is called `make.sh` and it's the script you will probably use
95% of time.  This script is responsible for building Docker container with
all dependencies and your projects same as for running `make` command in it.
The overall syntax is described in [usage](#Usage) section.  The later one
script, called `run_container.sh`, is much simpler and it's purpose is only
to build exactly the same container as used in `make.sh` and `exec` you into
it - run interactive `shell` in it.  In general, you should never need to
exec into Docker container, but we all know, that there actually are issues
like "It works on my computer" and you may sometimes need to examine real
cause of your problems from inside of the container.

## Usage

This `Dockerfile` together with shell scripts should be located in root
directory of your workspace, which means one level above Makefiles of
individual projects.  The expected structure is this:

```
- root
  - .dockerignore
  - Dockerfile
  - make.sh
  - run_container.sh
  - your_project_A
    - Makefile
    - include
      - ...
    - src
      - ...
  - your_project_B
    - Makefile
    - include
      - ...
    - src
      - ...
```

Then syntax used to run `make flash` command in project `project_A` is: 

```
./make.sh project_A flash
```

In the case of multiple build targets (for example `flash` and `swo`), use
following command:

```
./make.sh project_A 'flash swo'
```

For `run_container.sh`, the script has only 7 lines, so I won't describe it
much. In general, the only usage you will need is the simplest one:

```
./run_container.sh
```

## Finding `STM32F4` board

As Docker and containers in general are intended to separate programs inside
container from physical state of the host machine, Docker instances aren't
by default allowed to access USB devices.  One, most trivial, solution is
using `--privileged` option while running Docker image.  On the other hand,
this runs container more or less with root privilege on your host which is
definitely not secure!  Even for trusted code, this is bad practice in
Docker.  Moreover, I am pretty sure you don't trust this random code you've
downloaded from public Git repository, do you?

As the solution, here comes again `make.sh` & `run_container.sh` scripts.
They both expect exactly one `STM32F4` board to be connected via USB and use
`lsusb` command to find it.  Docker then runs with `--device` option, which
gives our container access only to `STM32F4` board instead of general
privileged access.  As you can see, this solution is much safer and it
didn't hurt too much.

## Best practices

- Don't disable Docker cache, as building would become remarkably slow.
- Write your `.dockerignore` file and list there all the files, you don't
  need to build project inside container. This approach will speed up your
  container build.
- In case of strange build errors, there is a script `run_container.sh` to
  interactively debug what's wrong.
- Stay aware of Docker container persistency and try to avoid code.
  modifications inside docker container, as those changes aren't persistent.
- When you are done, run `docker system prune --all --force --volumes` to
  clean Docker cache. This saves your disk space, but more importantly
  resources like `btrfs` sub-volumes which are heavily used by `docker`.

## Requirements

- `docker`
- `shell`
- `lsusb` command
- `dirname` command

---

## How about IDE?

There is one aspect of development not covered by this toolbox - coding
itself.  Sure, someone simply loves `vim` and refuses any king of IDE.  On
the other hand, there is a majority of programmers (including me) who are
used to IntelliSense, goto definition, and many other "modern" features.  So
let's discuss how to setup your IDE or at least how I did it.  If you would
find a better way, you are definitely welcome to send me a merge request.

`VS Code` is an IDE I've got quite used to. So I will discuss setup of this
IDE.  Honestly, I don't like `Java` based IDEs (`Eclipse`, `IntelliJ`).
This disfavour isn't caused by `Java` itself.  They are just too complex to
me.  Loading is long, menu is complex, and finding a required feature
requires half a day.  So I am sorry, if I won't discuss your favorite IDE.

First of all, I should state that I'm not assuming ability of `VS Code` to
build or debug my code.  I am used to work from console, so it doesn't make
me a problem to run `./make.sh` script by hand.  If you would like to spend
half a day connecting this script to your IDE, you can.  I recommend you
not to do that.  You only will be frustrated.

So the only obligatory ability for me is `IntelliSense`.  But here comes a
problem: The only place containing HAL library code is inside the Docker
image.  The only solution I've found is to clone `STM32CubeF4` repo again to
the current working directory as a separate project.  So my real directory
structure goes as follows:

```
- root
  - .dockerignore
  - Dockerfile
  - make.sh
  - run_container.sh
  - stm32f4cube         # Git cloned STM32CubeF4 repo
    - README.md
    - ...
  - my_project_A
    - Makefile
    - include
      - ...
    - src
      - ...
  - my_project_B
    - Makefile
    - include
      - ...
    - src
      - ...
```

I had the only problem with this approach - `stm32CubeF4` itself is `>1GB`.
Fortunately, the solution was quite easy.  Majority of that size volume was
documentation, example projects etc.  So we can remove all of those.
Pretty sure that you will remove some parts of code which are important for
building the project? But we don't want to build it, do we?  We only need
`IntelliSense`, so the only code we wan't to keep is under `/Drivers/BSP`
and `/Drivers/STM32F4xx_HAL_Driver`.  Most of the other directories can be
removed.  As the result, it's not too hard to reduce `stm32f4cube` below `~50
MiB`.

And now, how to set up the IDE.  I wanted my setup to be as simple as
possible, so I've done a small trade-off between easy setup and comfortable
usage.  Namely, I've decided to run my IDE always from `root` directory.  So
individual projects like `stm32f4-blink` and `stm32CubeF4` have become
sub-directories of my working directory.  The setup for `IntelliSense`:

```
"C_Cpp.default.includePath": [
        "${workspaceFolder}/stm32f4cube/Drivers/STM32F4xx_HAL_Driver/Inc",
        "${workspaceFolder}/stm32f4cube/Drivers/CMSIS/Core/Include",
        "${workspaceFolder}/stm32f4cube/Drivers/BSP/STM32F4-Discovery",
        "${workspaceFolder}/stm32f4-rtos/FreeRTOS/include",     # For RTOS
        "${fileDirname}",
],
```

Simple, isn't it? ☺

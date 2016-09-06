# Undertale NES demo

![Screenshot](progress/4.png)

This is a work in progress!

This is a fun little NES hombrew project I started.
It recreates the Lesser Dog battle from Undertale.

## How to build

You will need gcc, make and Python 3.5 to build this project.

Simply run `make` in your terminal of choice:

```bash
$ make
```

## How to play the game

The build process will create a NES ROM file in bin/main.nes.
You will need an emulator to play the game.
I recommend using [FCEUX](http://www.fceux.com/web/home.html).


## Install Python with Conda

Conda is a popular package management and virutal environment solution for
Python.

```
conda create -n undertale-nes python=3.5 jupyter networkx graphviz
pip install nxpd
```

# Welcome to the release of nulledSeries.

-----

## Introduction
I have decided to release the source code for nulledSeries for educational purposes and for my dedicated users who have continued to use it despite my inactivity (god bless your souls).

In releasing this, I hope that some people put it to good use, and continue it on - whether that be an experienced developer, or just someone starting out. Maybe when I check back after 6 months time, or a year, it would be nice to see it being updated.

-----

## The code
Some of the code is quite old and needs a refactor (I'm looking at you Lulu.lua...). It was goal around 2 months ago to full re-write the entire AIO, but due to time constraints and lack of motivation for anything league related, I never got around to doing so.

*Note: I have removed auth urls and debug-hack-prevention code - that's something you need to add yourself.*

-----

## How to build and run
In the folder structure, I have included a `./LuaJIT-2.1` directory which contains the binaries for LuaJIT. This will be used to run the `./squish.lua` script which compiles every included file in `./squishy` and `./map.txt` into 1 `.lua` file within the `./output` directory.

I have conveniently given you a `./Build.bat` script that will do all of the hard work for you, all you need to do is to update `./squishy` and `./map.txt` when ever you add a new file you wish to include.

-----

## Support
Unfortunately no support will be given at this time, hopefully you'll be able to read through the code yourself and figure out what it's doing. I don't believe it to be overly complex.

All of the common functions are within `./Utility/Utility.lua` and every class should be accessible from the `./SDK.lua` `SDK` global.

There is also a `./Champions/TEMPLATE.lua` file that should contain a template; used to create a new champion boilerplate.
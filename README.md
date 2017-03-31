# NorkEngine

Turo Pascal 7.0 Game Engine

The engine contains the work of me, Laszlo-Andras Zsurzsa from 2009. The goal of this repository is to provide as it is, the code. The code will be released open-source. In the future I would like to modernize the code and change the rendering to OpenGL in order to be able to provide a donwlodable solution for multiple OS.

Link to the open-source project: [Not defined]

 # Folder structure

1. Core: will contain the xxx.pas files that contain the core functionality of the engine. This classes and utility functions define the behaviour of the engine.

2. Sprite Editor: the application can be used to draw simple images for the game engine or for the future projects. The TP engine does not have the modality to use any kind of standard image files. The decision I made back then in 2009, because of multiple reasons. First of all it's easier to use the color's of the standard TP palette. Secondly it's easier to handle simple color matrixes in the game because of memory and logical processes.

3. Terrain Editor: the application can generate map's for the engine. All map's until now are 2D isometric styled. Of course it's easy to modify the engine and draw any kind of 2D game. (Top down 2D, platformer etc.)

4. Nork: the application is a not finished turn-based semi-real time strategy game that was never finished. I didn't made up my mind about finishing the game in TP or just simply start an open-source game engine or an open-source strategy game. This depends on the remaining posibilities of memory handling in the game. TP has not a huge amount of memory that one can use but it's still might be enough. Sadly, Back in 2009 and since then I had no more time to finish the game.

# Coding standard's

When ever there is the need to explain something in the code the following coding styles will be applied through the whole project.

1. Variables

2. Function's

3. Classes

Every class needs to have a comment before declaration, with the following style:

{************************************************************}

{*                     TScreen class                        *}

{*                    --------------                        *}

{*    Description etc.                                      *}

{************************************************************}

4. Code comments

Describing the code should be done only in the case it is really necesarry. The comment can be above or to the right of to the code, depending on the length of the comment.

{ - Description etc. }

# Disclaimer

The Mouse.TPU is not my work, so no responsability held in reusing the unit file. The source is unknown. The LICENSE is only valid on my work.

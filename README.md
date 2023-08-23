# LootLocker-Godot-SDK

## Disclaimer
This was just the beginning of an SDK for _Godot_. The _LootLocker_ Team said that it has plans for an official _Godot_ SDK, but as for now, this is what Ares2 came up with.

It also by far does not cover all the LootLocker features as Ares2 have just added the most important features that are needed. Those include:

- User authentication (guest login, white label login, Steam & Google will come later first)
- Leaderboards (almost all features)
- some misc features (ping)

This is a work in progress, it is barely usable for now, so **DO NOT** report issue as there are plenty, known or not yet known. You still can submit PR for features, bug fix or other things.

Stay tuned.

## Quick Start

TODO

## Introduction

## Installation

### [Setup](./documentation/setup/setup.md)

## Usage

### Authentication

## Demos included

### [SDK init](./src/demo/scripts/test-SDKinit.gd)

This sample shows how to initialize the SDK in order to use it with your game.

### [ping test](./src/demo/scripts/ping_test.gd)

Just a little sample of _ping_ call.

### guest login demo

As the title suggest, this is the basic authentication to LootLocker backend. It is used to hide auth mechanism from players who just want to play your game without having to create first another account somewhere and give away tons of private informations :).

### white label demo

As opposite to the previous auth method, this one use email/password combination and account creation, with eail verification step. It is used to deal with various features like plyers's inventory, progression, mission, and many more, where a dedicated account is more than needed and worth the time spent.

### generate data

A little program to create many random players at once and submit random score to a given leaderboard.Mostly for testing purpose.

### fake game demo

This is what a game could be regarding player auth & leaderboard interactions.

## Sample game provided

### Dodge the creeps official tutorial game

TODO (add guest login + leaderboard, then maybe a WL version of auth)

## Q & A

### What is LootLocker ? What are the benefits from this thing ? And all other LootLocker related questions.

Best answers you can get are already available at [LootLocker documentation website](https://docs.lootlocker.com/the-basics/what-is-lootlocker), you are strongly advised to go there, read and decide if _LootLocker_ can be of any help to your project.

### Does this SDK will be compatible with other platform SDK made by LootLocker ?

Short answer: no.
It doesn't make sense to me to replicate the exact same thing of the Unity and Unreal SDK, at least for now, as why on Earth and in the Universe, someone would want easy transition from Unity/Unreal to/from Godot for a given project ? All these engines are competitors on the same field.
Of course, for quite an upgrade from a free engine which is not yet mature to a "better" competitor, it make sense, anyway, nothing is carved in stone and also programming, and game programming, is also a matter of adapt and evolve, so anyone good enough could figure out how to use one feature or another no matter how it is implemented in a SDK or another.

### Which Godot version is supported ?

This SDK is currently coded using **4.2-dev3** release of _Godot_ engine, it will be most likely compatible with the most up to date 4.x release ONLY. And further releases as they'll come.
It has only been tested on _Windows_ for now. It may or may not work on other platforms.

### Does this SDK is usable ?

Right now, not really, as error management especially is really really bad (it sucks to be honest) ! DO NOT use it YET, be patient, contribute if you can and will.

### What is the plan for the following weeks/months ?

To continue working on the core of the SDK (low-level HTTPRequest handler and error management), add more _LootLocker_ features, in random order:
* Google Auth,
* Steam Auth,
* some Player stuff,
* things I don't know yet (achievements for instance, if they are added soon)


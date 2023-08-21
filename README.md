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

### Setup files

### Project setup

## Usage

### Authentication

#### Guest Login

#### White Label

#### Platform Login
TODO

## Demos included

### SDK init

This sample shows how to initialize the SDK in order to use it with your game.

### ping test

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

### What is LootLocker ? What are the benefits from this thing ? And all other LootLocker related questions

Best answers you can get are already available at [LootLocker documentation website](https://docs.lootlocker.com/the-basics/what-is-lootlocker), you are strongly advised to go there, read and decide if _LootLocker_ can be of any help to your project.

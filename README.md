# CA261 Assignment - Checkers in MIPS Assembly

English checkers (8x8) for two players, written in MIPS Assembly for the
MARS simulator.

## Status

Work in progress. No playable version yet.

## Game summary

- Two players, Black and Red, take turns on the same terminal. Black moves first.
- The board is printed every turn. Players enter moves as square numbers
  (1-32, standard checkers notation).
- Pawns move and capture diagonally forward. Kings move and capture in
  both directions.
- Chain captures are mandatory once a capture has been made.
- A player wins when the opponent has no pieces left.

## Requirements

- [MARS](https://dpetersanderson.github.io/) MIPS simulator (requires Java).

## Author

Nguyen To Quoc Viet

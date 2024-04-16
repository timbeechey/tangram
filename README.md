# Tangram Referential Communication Task

A gamified implementation of the referential communication task described by [Beechey et. al. (2019)](https://doi.org/10.1044/2018_JSLHR-H-18-0107).

The task requires the participant to find a path from the top-left cell of the grid to the bottom-right cell by moving horizontally or vertically between cells which share either the same colour or the same tangram image.

![puzzle](https://github.com/timbeechey/tangram/blob/main/puzzle.gif)

In two-participant mode each person sees only half the puzzle content with each individual having a complementary view which is not sufficient to navigate through the puzzle alone. The task for two participants is to verbally exchange information with each other to make it possible for both participants to find a path through the puzzle together.

![two-player](https://github.com/timbeechey/tangram/blob/main/two-player.gif)

Moves are recorded in a CSV file along with timestamps for later analysis.

# Building from source

To build the source first install the [love2d](https://www.love2d.org/) game engine and the [boon](https://github.com/camchenry/boon) build tool. To create a Windows executable, run the command from within the source directory:

```
boon build . --target windows
```

To create a Mac application use the `--target macos` option.

```
boon build . --target macos
```

# Running the game

The game executable can be run by double clicking on the application icon. A start-up menu provides text boxes to enter the ID and group of each participant. In two-participant mode, participants must be assigned to `player 1` or `player 2` to ensure the participants have complementary views. To ensure that each participant sees the same randomly generated puzzles, the same random seed must be entered for both participants.



![game_menu](https://github.com/timbeechey/tangram/blob/main/game_menu.jpg)

# References

Beechey, T., Buchholz, J. M., & Keidser, G. (2019). Eliciting naturalistic conversations: A method for assessing communication ability, subjective experience, and the impacts of noise and hearing impairment. _Journal of Speech, Language, and Hearing Research_, 62(2), 470–484. https://doi.org/10.1044/2018_JSLHR-H-18-0107

# Tangram Referential Communication Task

A gameified implementation of the referential communication task described by Beechey et. al. (2019).

The task requires the player to find a path from the top-left cell of the grid to the bottom-right cell by moving horizontally or vertically between cells which share either the same colour or the same tangram image.

![puzzle](https://github.com/timbeechey/tangram/assets/66388815/21720f9b-eb8e-4a1f-8d10-e77d3640e9ba)

In two-player mode each player sees only half the puzzle content with each player having a complementary view. The task for two players is to verbally exchange information with one-another to make it possible for both players to find a path through the puzzle. 

<img source="https://github.com/timbeechey/tangram/assets/66388815/1563d49a-1261-4368-80df-e4c81a1a6e48", width="200"><img source="https://github.com/timbeechey/tangram/assets/66388815/c67cf728-8609-4c31-a86f-b352c7b309ab", width="200">

# Building the game

To build the source first install the [love2d](https://www.love2d.org/) game engine. The download the [boon](https://github.com/camchenry/boon) build tool. From within the source directory execute the command:

```
boon build . --target windows
```

to create a Windows executable. Or:

```
boon build . --target macos
```

to create a MacOS application.

# References

Beechey, T., Buchholz, J. M., & Keidser, G. (2019). Eliciting naturalistic conversations: A method for assessing communication ability, subjective experience, and the impacts of noise and hearing impairment. _Journal of Speech, Language, and Hearing Research_, 62(2), 470–484. https://doi.org/10.1044/2018_JSLHR-H-18-0107

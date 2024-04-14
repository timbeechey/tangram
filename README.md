# Tangram Referential Communication Task

A gameified implementation of the referential communication task described by Beechey et. al. (2019).

The task requires the player to find a path from the top-left cell of the grid to the bottom-right cell by moving horizontally or vertically between cells which share either the same colour or the same tangram image.

![puzzle](https://github.com/timbeechey/tangram/assets/66388815/21720f9b-eb8e-4a1f-8d10-e77d3640e9ba)

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

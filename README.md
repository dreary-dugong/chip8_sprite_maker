# Chip-8 Sprite Maker
A small aseprite script I wrote to convert a selected region into the text format
used for my chip-8 assembler. It requires a selection on the active layer and needs
a file name to save to and a name for the sprites. The selection will automatically
be broken up into multiple 8-pixel chunks to fit in chip-8's byte format. Empty
pixels will be applied as padding on either the left or right according to the user's
choice. 
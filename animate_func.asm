################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       1
# - Unit height in pixels:      1
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################


##############################################################################
# Macros
##############################################################################
# The macro for pushing a value onto the stack.
.macro push (%reg) 
    addi $sp, $sp, -4       # move the stack pointer to the next empty spot
    sw %reg, 0($sp)         # push the register value onto the top of the stack
.end_macro

# The macro for popping a value off the stack.
.macro pop (%reg) 
    lw %reg, 0($sp)         # fetch the top element from the stack    
    addi $sp, $sp, 4        # move the stack pointer to the top element of the stack.
.end_macro

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

# The address of the additional grid for removal function
ADD_GRID:
    .space 16384

# The address of the orientation grid for keeping track of capsule halves
ORI_GRID:
    .space 16384

DROP_SPD:
    .space 4

    
##############################################################################
# Code
##############################################################################
	.text
    .globl main

main:
  li $a0 0
  li $a1 0
  li $a2 64
  li $a3 64
  li $t1 0x4000f8

  jal draw_rect
  
  jal draw_bg

  li $v0, 10                      # Quit gracefully
  syscall



  



draw_bg:
  push ($ra)


  jal draw_yellow

  jal draw_orange

  jal draw_green

  jal draw_mario

  jal draw_big_cap


  pop ($ra)
  jr $ra




draw_yellow:
  push ($ra)

  li $t1 0xFFCE55           # load in yellow

  li $a0 9
  li $a1 4
  li $a2 4
  li $a3 12

  jal draw_rect

  li $a0 8
  li $a1 5
  li $a2 1
  li $a3 11

  jal draw_rect

  li $a0 13
  li $a1 5
  li $a2 1
  li $a3 11

  jal draw_rect

  li $a0 7
  li $a1 6
  li $a2 1
  li $a3 10

  jal draw_rect
  

  li $a0 14
  li $a1 6
  li $a2 1
  li $a3 10

  jal draw_rect

  
  li $a0 14
  li $a1 6
  li $a2 1
  li $a3 10

  jal draw_rect


  li $a0 4
  li $a1 10
  li $a2 13
  li $a3 5

  jal draw_rect

  li $a0 17
  li $a1 9
  li $a2 1
  li $a3 5

  jal draw_rect

  li $a0 18
  li $a1 9
  li $a2 1
  li $a3 1

  jal draw_rect

  
  li $a0 2
  li $a1 12
  li $a2 1
  li $a3 1

  jal draw_rect



# sunglasses and outline

  li $t1 0

  li $a0 10
  li $a1 3
  li $a2 2
  li $a3 1

  jal draw_rect


  li $a0 9
  li $a1 4
  li $a2 1
  li $a3 1

  jal draw_rect


  li $a0 12
  li $a1 4

  jal draw_rect


  li $a0 8
  li $a1 5

  jal draw_rect

  li $a0 13
  li $a1 5

  jal draw_rect

  li $a0 7
  li $a1 6

  jal draw_rect


  li $a0 14
  li $a1 6

  jal draw_rect

  li $a0 6
  li $a1 7

  jal draw_rect

  li $a0 15
  li $a1 7

  jal draw_rect


  li $a0 5
  li $a1 8
  li $a2 3
  li $a3 3

  jal draw_rect

  li $a0 14
  li $a1 8

  jal draw_rect

  li $a0 7
  li $a1 8
  li $a2 8
  li $a3 1

  jal draw_rect

  li $a0 7
  li $a1 8
  li $a2 3
  li $a3 2

  jal draw_rect

  li $a0 12
  li $a1 8

  jal draw_rect

  li $a0 2
  li $a1 11
  li $a2 2
  li $a3 1

  jal draw_rect

  li $a0 4
  li $a1 9
  li $a2 4
  li $a3 2

  jal draw_rect

  li $a0 14
  li $a1 9

  jal draw_rect


  #hands + feet

  li $t1 0xF16838

  li $a0 2
  li $a1 13
  li $a2 3
  li $a3 4

  jal draw_rect

  li $a0 6
  li $a1 16
  li $a2 3
  li $a3 1

  jal draw_rect

  li $a0 13
  li $a1 16

  jal draw_rect

  li $a0 20
  li $a1 6
  li $a2 2
  li $a3 4

  jal draw_rect


# more outlining

  li $t1 0

  li $a0 3
  li $a1 12
  li $a2 1
  li $a3 1

  jal draw_rect

  li $a0 4
  li $a1 13
  li $a3 2
  

  jal draw_rect


  li $a0 1
  li $a1 12
  li $a2 1
  li $a3 5

  jal draw_rect


  li $a0 2
  li $a1 17
  li $a2 3
  li $a3 1

  jal draw_rect

  li $a0 4
  li $a1 16
  li $a2 2
  li $a3 1

  jal draw_rect

  li $a0 5
  li $a1 14
  li $a2 1
  li $a3 3

  jal draw_rect

  li $a0 6
  li $a1 15
  li $a2 11
  li $a3 1

  jal draw_rect


  li $a0 6
  li $a1 17
  li $a2 4
  li $a3 1

  jal draw_rect


  li $a0 12
  li $a1 17

  jal draw_rect


  li $a0 9
  li $a1 15
  li $a2 1
  li $a3 3

  jal draw_rect


  li $a0 12
  li $a1 15

  jal draw_rect


  li $a0 16
  li $a1 14

  jal draw_rect

  li $a0 18
  li $a1 10

  jal draw_rect

  li $a0 17
  li $a1 13
  li $a2 1
  li $a3 1

  jal draw_rect

  li $a0 18
  li $a1 8

  jal draw_rect

  li $a0 2
  li $a1 13

  jal draw_rect


# mouth
  li $a0 6
  li $a1 12

  jal draw_rect

  li $a0 15
  li $a1 12

  jal draw_rect

  li $a0 7
  li $a1 13
  li $a2 8
  li $a3 1

  jal draw_rect


# mouth end

  li $a0 19
  li $a1 5
  li $a2 1
  li $a3 6

  jal draw_rect

  li $a0 19
  li $a1 5
  li $a2 2
  li $a3 1

  jal draw_rect

  li $a0 21
  li $a1 6
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 22
  li $a1 7
  li $a2 1
  li $a3 4

  jal draw_rect

  li $a0 19
  li $a1 10
  li $a2 4
  li $a3 1

  jal draw_rect


# eyes

  li $t1 0xDBF68F

  li $a0 8
  li $a1 9
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 13
  li $a1 9

  jal draw_rect



  pop ($ra)

  jr $ra



draw_orange:
  push ($ra)

  li $t1 0xF16838

  li $a0 4
  li $a1 26
  li $a2 11
  li $a3 9

  jal draw_rect

  li $a0 4
  li $a1 24
  li $a2 3
  li $a3 2

  jal draw_rect

  li $a0 12
  li $a1 24

  jal draw_rect


  li $a0 3
  li $a1 26
  li $a2 1
  li $a3 2

  jal draw_rect


  li $a0 15
  li $a1 26
  
  jal draw_rect


  li $a0 3
  li $a1 33
  li $a2 1
  li $a3 1

  jal draw_rect


  li $a0 15
  li $a1 33

  jal draw_rect


  li $a0 5
  li $a1 35
  li $a2 3
  li $a3 1

  jal draw_rect

  li $a0 11
  li $a1 35

  jal draw_rect


# hands and feet

  li $t1 0xDBF68F

  li $a0 1
  li $a1 32
  li $a2 2
  li $a3 2

  jal draw_rect

  li $a0 16
  li $a1 32

  jal draw_rect

  li $a0 3
  li $a1 36
  li $a2 4
  li $a3 2

  jal draw_rect

  li $a0 12
  li $a1 36

  jal draw_rect


# outlining

  li $t1 0

  li $a0 7
  li $a1 24
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 11
  li $a1 24

  jal draw_rect

  li $a0 8
  li $a1 25

  jal draw_rect

  li $a0 10
  li $a1 25

  jal draw_rect

  li $a0 2
  li $a1 26

  jal draw_rect

  li $a0 16
  li $a1 26

  jal draw_rect

  li $a0 7
  li $a1 25
  li $a2 5
  li $a3 1

  jal draw_rect

  li $a0 5
  li $a1 23
  li $a2 2
  li $a3 1

  jal draw_rect

  li $a0 12
  li $a1 23

  jal draw_rect

  li $a0 4
  li $a1 24
  li $a2 1
  li $a3 1

  jal draw_rect

  li $a0 3
  li $a1 25

  jal draw_rect

  li $a0 14
  li $a1 24

  jal draw_rect

  li $a0 15
  li $a1 25

  jal draw_rect

  li $a0 15
  li $a1 25

  jal draw_rect

  li $a0 3
  li $a1 28

  jal draw_rect

  li $a0 15
  li $a1 28

  jal draw_rect

  li $a0 5
  li $a1 28
  li $a2 3
  li $a3 3

  jal draw_rect

  li $a0 11
  li $a1 28

  jal draw_rect

  li $a0 4
  li $a1 29
  li $a2 2
  li $a3 3

  jal draw_rect

  li $a0 13
  li $a1 29

  jal draw_rect

  li $a0 8
  li $a1 30
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 10
  li $a1 30

  jal draw_rect

  li $a0 9
  li $a1 31

  jal draw_rect

  li $a0 6
  li $a1 34
  li $a2 6
  li $a3 1

  jal draw_rect

  li $a0 11
  li $a1 33
  li $a2 2
  li $a3 1

  jal draw_rect

  li $a0 12
  li $a1 32
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 8
  li $a1 35
  li $a2 3
  li $a3 1

  jal draw_rect

  li $a0 15
  li $a1 31

  jal draw_rect

  li $a0 1
  li $a1 34

  jal draw_rect

  li $a0 15
  li $a1 34

  jal draw_rect

  li $a0 5
  li $a1 36

  jal draw_rect

  li $a0 11
  li $a1 36

  jal draw_rect


  li $a0 1
  li $a1 31
  li $a2 5
  li $a3 1

  jal draw_rect
  
  li $a0 3
  li $a1 31
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 15
  li $a1 31

  jal draw_rect
  
  li $a0 0
  li $a1 32

  jal draw_rect

  li $a0 18
  li $a1 32

  jal draw_rect

  li $a0 2
  li $a1 33

  jal draw_rect

  li $a0 16
  li $a1 33

  jal draw_rect

  li $a0 7
  li $a1 36

  jal draw_rect

  li $a0 11
  li $a1 36

  jal draw_rect

  li $a0 3
  li $a1 35
  li $a2 2
  li $a3 1

  jal draw_rect

  li $a0 14
  li $a1 35

  jal draw_rect

  li $a0 16
  li $a1 36
  li $a2 1
  li $a3 3

  jal draw_rect

  li $a0 2
  li $a1 36

  jal draw_rect

  li $a0 2
  li $a1 38
  li $a2 5
  li $a3 1

  jal draw_rect

  li $a0 12
  li $a1 38

  jal draw_rect


# eyes
  li $t1 0xFFCE55

  li $a0 7
  li $a1 30
  li $a2 1
  li $a3 2

  jal draw_rect

  li $a0 11
  li $a1 30

  jal draw_rect


  pop ($ra)

  jr $ra



draw_green:
  push ($ra)



  pop ($ra)

  jr $ra


draw_mario:
  push ($ra)


  pop ($ra)

  jr $ra



draw_big_cap:
  push ($ra)

  li $t1 0xF16838



  pop ($ra)

  jr $ra









####################################
## The rectangle drawing function ##
####################################
# Input parameters:
# - $a0: X coordinate of the top left corner of the rectangle
# - #a1: Y coordinate of the top left corner of the rectangle
# - $a2: Width of the rectangle
# - $a3: Height of the rectangle
draw_rect:
  add $t5 $zero $zero       # setting the loop variable to 0
  line_draw_start:
    addi $sp, $sp, -4                # Move the stack pointer to an empty location
    sw $a1, 0($sp)                  # Store $a1 on the stack for safe keeping.
    addi $sp, $sp, -4                # Move the stack pointer to an empty location
    sw $t5, 0($sp)                  # Store $t5 on the stack for safe keeping.
    addi $sp, $sp, -4                # Move the stack pointer to an empty location
    sw $ra, 0($sp)                  # Store $ra on the stack for safe keeping.
    addi $sp, $sp, -4                # Move the stack pointer to an empty location
    sw $a0, 0($sp)                  # Store $a0 on the stack for safe keeping.
    
    jal draw_hline                   # draw a line (using the X, Y and width parameters)
    
    lw $a0, 0($sp)                  # Restore $a0 from the stack.
    addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
    lw $ra, 0($sp)                  # Restore $ra from the stack.
    addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
    lw $t5, 0($sp)                  # Restore $t5 from the stack.
    addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
    lw $a1, 0($sp)                  # Restore $a1 from the stack.
    addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.

    addi $t5 $t5 1                  # increment loop var by 1 after drawing one line
    addi $a1 $a1 1                  # increment y coordinate after each line
    
    beq $t5, $a3, line_draw_end     # break out of the loop if you hit the final row
    j line_draw_start               # jump to the start of the row drawing loop
  line_draw_end:  
    jr $ra                          # return to the calling program








  
## The horizontal line drawing function ## WORKS!!
# Input parameters:
# - $a0: X coordinate of the start of the line
# - #a1: Y coordinate of the start of the line
# - $a2: Length of the line
draw_hline:
  add $t5 $zero $zero               # setting the counter to 0

  addi $t3 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t4 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t3 $a0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t4 $a1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  la $t6 ADDR_DSPL
  lw $t0 0($t6)

  add $t7 $t0 $v0                 # setting the horizontal offset
  add $t7 $t7 $v1                 # setting the vertical offset

  
  hpixel_draw_start:                 # the starting label for the pixel drawing loop
    sw $t1, 0( $t7 )                # paint the current bitmap location.
    
    addi $t5 $t5 1                  # add 1 to the counter
    addi $t7, $t7, 4                # move to the next pixel in the row.
    beq $t5, $a2, hpixel_draw_end     # break out of the loop if you hit the final pixel
    j hpixel_draw_start              # otherwise, jump to the top of the loop
  hpixel_draw_end:                   # the label for the end of the pixel drawing loop
  jr $ra 


  
  
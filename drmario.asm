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


##############################################################################
# Mutable Data
##############################################################################

# x-coordinate of the current capsule
CAPSULE_X:
    .word 0

# y-coordinate of the current capsule
CAPSULE_Y:
    .word 0

# keeps track of capsule orientation, 0 for horizontal (c1 c2), 1 for vertical 
# (c1 on top, c2 bottom), 2 for horz (c2, c1), 3 for (c2 top, c1 bottom)
CAPSULE_O:
    .word 0

COLOR1:
    .word 0

COLOR2:
    .word 0


    
##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    li $t1, 0x568366        # $t1 = green
    addi $a0 $zero 1        # setting the x pos of rect
    addi $a1 $zero 1        # setting the y pos of rect
    addi $a2 $zero 62       # setting width of the rect
    addi $a3 $zero 62       # setting height of the rect
    
    jal draw_rect           # call the rectangle drawing function
    
    jal draw_bottle
    
    jal draw_start_capsule


# a0: x pos
# a1: y pos
# a2: orientation, 0 for h, 1 for v
game_loop:
    # 1: drawing the capsule at the bottle neck
    li $a2 0                      # load in horizontal orientation
 
    # check keyboard action for this loop
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed

    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    j game_loop


# a0: x pos
# a1: y pos
# a2: orientation, 0 for h, 1 for v
# calling a3: 'a', 'd', 's', 'w'
keyboard_input:
    addi $sp, $sp, -4       # Push $ra onto stacsk
    sw $ra, 0($sp)

    lw $t1, 4($t0)          # Load second word from keyboard
    
    beq $t1, 'a', call_move_left  

    beq $t1, 'd', call_move_right 
    
    beq $t1, 's', call_move_down  
    
    beq $t1, 'w', call_rotate     
    
    beq $t1, 'q', call_quit       

    j keyboard_end          # If no valid input, skip function calls

  call_move_left:
      jal move_left   
      j keyboard_end
  
  call_move_right:
      jal move_right  
      j keyboard_end
  
  call_move_down:
      jal move_down   
      j keyboard_end
  
  call_rotate:
      jal rotate      
      j keyboard_end
  
  call_quit:
      jal quit        
      j keyboard_end
  
  keyboard_end:
      lw $ra, 0($sp)          # Restore $ra
      addi $sp, $sp, 4        # Pop stack
      jr $ra     



move_left:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)
  
  
  la $t3 CAPSULE_X           # get the memory location of CAPSULE_X
  lw $a0 0($t3)              # get the x coordinate of the curr capsule

  
  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule


  la $t3 CAPSULE_O           # get the memory location of ORIENTATION
  lw $t0 0($t3)              # get the y coordinate of the curr capsule


  jal left_collision
  
  beq $t1, $zero, move_left_end   # check if we are at left bottle wall, if true then we skip over to the end (t1 is set to 0 if collision)

  # not at bottle wall

  jal erase_capsule


  # draw the updated capsule
  
  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule

  la $t3 CAPSULE_X           # get the memory location of CAPSULE_X
  lw $a0 0($t3)              # get the x coordinate of the curr capsule

  addi $a0 $a0 -3            # move it to the left by 3

  sw $a0 0($t3)              # write it back to the x pos

  jal capsule

  move_left_end:

  lw $ra 0($sp)
  addi $sp $sp 4

  jr $ra
  

move_right:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)
  
  
  la $t3 CAPSULE_X           # get the memory location of CAPSULE_X
  lw $a0 0($t3)              # get the x coordinate of the curr capsule

  
  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule


  la $t3 CAPSULE_O           # get the memory location of ORIENTATION
  lw $t0 0($t3)              # get the y coordinate of the curr capsule

  jal right_collision
  
  beq $t1, $zero, move_right_end   # check if we are at left bottle wall, if true then we skip over to the end (t1 is set to 0 if collision)

  # not at bottle wall

  jal erase_capsule

  # draw the updated capsule
  
  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule

  la $t3 CAPSULE_X           # get the memory location of CAPSULE_X
  lw $a0 0($t3)              # get the x coordinate of the curr capsule

  addi $a0 $a0 3            # move it to the left by 3

  sw $a0 0($t3)              # write it back to the x pos

  jal capsule

  move_right_end:
    
  lw $ra 0($sp)
  addi $sp $sp 4

  jr $ra
  

move_down:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)
  
  la $t3 CAPSULE_X           # get the memory location of CAPSULE_X
  lw $a0 0($t3)              # get the x coordinate of the curr capsule
  
  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule

  la $t3 CAPSULE_O           # get the memory location of ORIENTATION
  lw $t0 0($t3)              # get the y coordinate of the curr capsule

  jal ycollision
  
  beq $t1, $zero, move_left_end   # check if we are at bottom bottle wall or block, if true then we skip over to the end (t1 is set to 0 if collision)

  # not at bottle wall

  jal erase_capsule
  
  # draw the updated capsule

  la $t3 CAPSULE_X           # get the memory location of CAPSULE_X
  lw $a0 0($t3)              # get the x coordinate of the curr capsule

  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule

  addi $a1 $a1 3            # move it to the left by 3

  sw $a1 0($t3)              # write it back to the x pos

  jal capsule

  lw $ra 0($sp)
  addi $sp $sp 4

  jr $ra
  

rotate:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)

  jal rotate_collision

  beq $t1 $zero rotate_end   # jump to end of rotation if there is a collision

  la $t3 CAPSULE_O           # getting current capsule orientation
  lw $t1 0($t3)

  beq $t1 $zero call_handle_h     # jump to handle_h branch in helpers section below

  li $t3 1
  beq $t1 $t3 call_handle_v       # jump to handle v branch in helpers section below

  call_handle_h:
    jal handle_h
    j rotate_end

  call_handle_v:
    jal handle_v
    j rotate_end
  
  rotate_end: 
  
  lw $ra 0($sp)
  addi $sp $sp 4

  jr $ra
  
  


quit:
  li $v0, 10                      # Quit gracefully
  syscall





# keyboard helpers


left_collision:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)

  la $t3 CAPSULE_X           # getting x value
  lw $t0 0($t3)

  la $t3 CAPSULE_Y           # getting x value
  lw $t1 0($t3)

  la $t3 CAPSULE_O           # getting orientation
  lw $t2 0($t3)

  la $t3 ADDR_DSPL           # getting the board start address
  lw $t4 0($t3)


  # getting the memory address of our capsule location
  
  addi $t5 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t6 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t5 $t0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t6 $t1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  add $t7 $t4 $v0                 # setting the horizontal offset
  add $t7 $t7 $v1                 # setting the vertical offset
  
  # register t7 now holds the correct memory address of our capsule location

  beq $t2 $zero left_h_collision    # checking to see if it's horizonal orientation and jump

  j left_v_collision              # else jump to vertical branch          

  left_h_collision:
    addi $t7 $t7 -12                 # moving to left capsule location
    lw $t2 0($t7)                   # loading t2 with the next pixel location

    li $t3 0x266533
    beq $t3 $t2 set_left_collision_end   # no collision!

    j set_left_collision               # else yes collision :(

  
  left_v_collision:
    addi $t7 $t7 -12                 # moving to left capsule location
    lw $t2 0($t7)                   # loading t2 with the next pixel location

    li $t3 0x266533
    beq $t3 $t2 v_left_col_check2 

    jal set_left_collision

    v_left_col_check2:
      addi $t7 $t7 -768                 # moving to check if upper half has space to move
      lw $t2 0($t7)                   # loading t2 with the next pixel location

      beq $t3 $t2 set_left_collision_end
      

  set_left_collision:
    li $t1 0
    
    j left_collision_return
    
  set_left_collision_end:
    li $t1 1
  
  left_collision_return:
    
  lw $ra 0($sp)                     # get $ra back
  addi $sp $sp 4

  jr $ra
  

right_collision:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)

  la $t3 CAPSULE_X           # getting x value
  lw $t0 0($t3)

  la $t3 CAPSULE_Y           # getting x value
  lw $t1 0($t3)

  la $t3 CAPSULE_O           # getting orientation
  lw $t2 0($t3)

  la $t3 ADDR_DSPL           # getting the board start address
  lw $t4 0($t3)

  # getting the memory address of our capsule location
  
  addi $t5 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t6 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t5 $t0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t6 $t1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  add $t7 $t4 $v0                 # setting the horizontal offset
  add $t7 $t7 $v1                 # setting the vertical offset
  
  # register t7 now holds the correct memory address of our capsule location

  beq $t2 $zero right_h_collision    # checking to see if it's horizonal orientation and jump

  j right_v_collision              # else jump to vertical branch          

  right_h_collision:
    addi $t7 $t7 24                 # moving to left capsule location
    lw $t2 0($t7)                   # loading t2 with the next pixel location

    li $t3 0x266533
    beq $t3 $t2 set_right_collision_end   # no collision!

    j set_right_collision               # else yes collision :(

  
  right_v_collision:
    addi $t7 $t7 12                 # moving to right capsule location
    lw $t2 0($t7)                   # loading t2 with the next pixel location

    li $t3 0x266533
    beq $t3 $t2 v_left_col_check2 

    j set_left_collision

    v_right_col_check2:
      addi $t7 $t7 -768                 # moving to check if upper half has space to move
      lw $t2 0($t7)                   # loading t2 with the next pixel location

      beq $t3 $t2 set_left_collision_end   # see if second half has collision
      
  set_right_collision:
    li $t1 0
    
    j right_collision_return
    
  set_right_collision_end:
    li $t1 1
  
  right_collision_return:
    
  lw $ra 0($sp)                     # get $ra back
  addi $sp $sp 4

  jr $ra
  



ycollision:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)

  la $t3 CAPSULE_X           # getting x value
  lw $t0 0($t3)

  la $t3 CAPSULE_Y           # getting y value (kate)
  lw $t1 0($t3)

  la $t3 CAPSULE_O           # getting orientation
  lw $t2 0($t3)

  la $t3 ADDR_DSPL           # getting the board start address
  lw $t4 0($t3)
  
  # getting the memory address of our capsule location
  
  addi $t5 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t6 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t5 $t0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t6 $t1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  add $t7 $t4 $v0                 # setting the horizontal offset
  add $t7 $t7 $v1                 # setting the vertical offset
  
  # register t7 now holds the correct memory address of our capsule location
  
  beq $t2 $zero y_h_collision    # checking to see if it's horizonal orientation and jump

  jal y_v_collision              # else jump to vertical branch  
  
  
  y_h_collision:
    addi $t7 $t7 768               # moving to bottom capsule location (3 rows down = 256*3 = 768)
    lw $t2 0($t7)                   # loading t2 with the next pixel location (kate: acc storing the colour at that location)
  
    li $t3 0x266533
    beq $t3 $t2 h_y_col_check2       # if equal, then new move valid ; if not equal, then collision
    j set_y_collision
    
    h_y_col_check2:             # this one checking if second half of pill collides with anything
    addi $t7 $t7 12             # moving to ghost location of second half of pill
    lw $t2 0($t7)               # loading t2 with next pixel location (of second half)
    
    beq $t3 $t2 set_y_collision_end   # see if second half has collision ; if equal, then no collision; if not equal, then collision
    
    j set_y_collision
  
  
  y_v_collision:            # in vertical orientation, checking if down movement causes collision
    addi $t7 $t7 768                 # moving to location of potential next move
    lw $t2 0($t7)                   # loading t2 with the next pixel location

    li $t3 0x266533                 # kate - dark green background
    beq $t3 $t2 set_y_collision_end   # no collision!

    j set_y_collision               # else yes collision :(
  
  
    set_y_collision:
      li $t1 0
      j y_collision_return
    
    set_y_collision_end:
      li $t1 1                    # 1 in t1 = no collision
     
    y_collision_return:
      lw $ra 0($sp)                     # get $ra back
      addi $sp $sp 4

      jr $ra




rotate_collision:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)

  la $t3 CAPSULE_X           # getting x value
  lw $t0 0($t3)

  la $t3 CAPSULE_Y           # getting y value
  lw $t1 0($t3)

  la $t3 CAPSULE_O           # getting orientation
  lw $t2 0($t3)

  la $t3 ADDR_DSPL           # getting the board start address
  lw $t4 0($t3)


  # getting the memory address of our capsule location
  
  addi $t5 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t6 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t5 $t0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t6 $t1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  add $t7 $t4 $v0                 # setting the horizontal offset
  add $t7 $t7 $v1                 # setting the vertical offset
  
  # register t7 now holds the correct memory address of our capsule location

  li $t3 0x266533                 # bg color to check

  beq $t2 $zero rotate_h_collision

  j rotate_v_collision

  rotate_h_collision:
    addi $t7 $t7 -768
    lw $t2 0($t7)
    beq $t2 $t3 set_rotate_collision_end

    j set_rotate_collision


  rotate_v_collision:
    addi $t7 $t7 12
    lw $t2 0($t7)
    beq $t2 $t3 set_rotate_collision_end

    j set_rotate_collision
    
  set_rotate_collision:
    li $t1 0
    
    j rotate_collision_end
    
  set_rotate_collision_end:
    li $t1 1
  
    
  rotate_collision_end:
    
  lw $ra 0($sp)                     # get $ra back
  addi $sp $sp 4

  jr $ra



handle_h:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)
  
  la $t3, CAPSULE_X               # loading x coordinate of capsule
  lw $a0 0($t3)
  
  la $t3, CAPSULE_Y               # loading y coordinate of capsule
  lw $a1 0($t3)

  li $t1 0x266533                # BG COLOR

  li $a2 6
  li $a3 3

  jal draw_rect                   # erasing last pill location

  la $t3, CAPSULE_X               # loading x coordinate of capsule
  lw $a0 0($t3)
  
  la $t3, CAPSULE_Y               # loading y coordinate of capsule
  lw $a1 0($t3)

  li $t1 1

  la $t3, CAPSULE_O               # loading orientation
  sw $t1 0($t3)                   # changing orientation 0 -> 1

  jal capsule
  
  lw $ra 0($sp)
  addi $sp $sp 4

  jr $ra
  



  
handle_v:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)
  
  la $t3, CAPSULE_X               # loading x coordinate of capsule
  lw $a0 0($t3)
  
  la $t3, CAPSULE_Y               # loading y coordinate of capsule
  lw $a1 0($t3)

  addi $a1 $a1 -3                 # moving y coordinate to corner of pill

  li $t1 0x266533                 # BG COLOR

  li $a2 3
  li $a3 6

  jal draw_rect                   # erasing last pill location

  la $t3, CAPSULE_X               # loading x coordinate of capsule
  lw $a0 0($t3)
  
  la $t3, CAPSULE_Y               # loading y coordinate of capsule
  lw $a1 0($t3)

  la $t3, CAPSULE_O               # loading orientation
  sw $zero 0($t3)                  # changing orientation 1 -> 0

  la $t3, COLOR1                  # loading color 1
  lw $t1 0($t3)
  
  la $t3, COLOR2                  # loading color 2
  lw $t2 0($t3)

  sw $t1 0($t3)                   # switch COLOR2 with COLOR1
  la $t3, COLOR1                  # loading color 1
  sw $t2 0($t3)                   # switch COLOR1 with COLOR2

  jal capsule
  
  lw $ra 0($sp)
  addi $sp $sp 4

  jr $ra
  




erase_capsule:
  addi $sp $sp -4            # push return value onto stack
  sw $ra 0($sp)

  la $t3 CAPSULE_X           # get the memory location of CAPSULE_Y
  lw $a0 0($t3)              # get the x coordinate of the curr capsule
  
  la $t3 CAPSULE_Y           # get the memory location of CAPSULE_Y
  lw $a1 0($t3)              # get the y coordinate of the curr capsule

  la $t3 CAPSULE_O           # get the memory location of ORIENTATION
  lw $t0 0($t3)              # get the orientation of capsule

  beq $t0 $zero horizontal_erase   # jump to horizontal erase line

  jal vertical_erase               # else jump to vertical erase line

  horizontal_erase:
    li $a2 6
    li $a3 3
    
    jal vertical_erase_end

  vertical_erase:
    li $a2 3
    li $a3 6

    addi $a1 $a1 -3

  vertical_erase_end:

  li $t1 0x266533                   # set bg color

  jal draw_rect                     # ERASE

  lw $ra 0($sp)                     # get $ra back
  addi $sp $sp 4

  jr $ra
  








####################################
##  The Capsule Drawing Function  ##
####################################
# Input parameters:
# - $a0: X coordinate of the top left corner of the capsule
# - #a1: Y coordinate of the top left corner of the capsule
draw_start_capsule:
  
  # adding $ra to stack
  addi $sp, $sp, -4                # Move the stack pointer to an empty location
  sw $ra, 0($sp)                  # Store $ra on the stack for safe keeping.


  # generating a random value for the color + orientation
  addi $a0 $zero 29               # setting up x,y coordinates of the capsule
  addi $a1 $zero 13

  la $t3, CAPSULE_X               # loading x coordinate of starting capsule to memory
  sw $a0 0($t3)
  
  la $t3, CAPSULE_Y               # loading y coordinate of starting capsule to memory
  sw $a1 0($t3)
  
  li $v0, 42
  li $a0, 0
  li $a1, 6
  syscall

  addi $a2 $zero 3                # setting up 1/2 capsule size
  addi $a3 $zero 3
  
  addi $t2 $zero 0
  beq $a0 $t2, capsule_0          # Jump to drawing capsule 0

  addi $t2 $zero 1
  beq $a0 $t2, capsule_1          # Jump to drawing capsule 1

  addi $t2 $zero 2
  beq $a0 $t2, capsule_2          # Jump to drawing capsule 2

  addi $t2 $zero 3
  beq $a0 $t2, capsule_3          # Jump to drawing capsule 3

  addi $t2 $zero 4
  beq $a0 $t2, capsule_4          # Jump to drawing capsule 4

  addi $t2 $zero 5
  beq $a0 $t2, capsule_5          # Jump to drawing capsule 5
  
  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
  
  jr $ra                          # return back to game_loop




####################################
##  The Capsules Section (0 - 5)  ##
####################################
# Input parameters:
# - $a0: X coordinate of the top left corner of the capsule
# - #a1: Y coordinate of the top left corner of the capsule
# - #t1: color1
# - #t2: color2

capsule_0:

  la $t3, COLOR1
  li $t1, 0xDBF68F        # c1 = sour apple
  sw $t1, 0($t3)

  la $t3, COLOR2
  li $t2, 0xFFCE55        # c2 = sunflower/golden yellow
  sw $t2, 0($t3)
  
  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)
  
  jal capsule

  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
  
  jr $ra                  # return back to draw_capsule


capsule_1:
  
  la $t3, COLOR1
  li $t1, 0xDBF68F        # c1 = sour apple
  sw $t1, 0($t3)

  la $t3, COLOR2
  li $t2, 0xF16838        # c2 = orange
  sw $t2, 0($t3)

  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  jal capsule

  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.

  jr $ra                          # return back to draw_capsule


capsule_2:

  la $t3, COLOR1
  li $t1, 0xFFCE55        # c1 = yellow
  sw $t1, 0($t3)

  la $t3, COLOR2
  li $t2, 0xF16838        # c2 = orange
  sw $t2, 0($t3)

  

  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  jal capsule

  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
  
  jr $ra                          # return back to draw_capsule


capsule_3:

  la $t3, COLOR1
  li $t1, 0xFFCE55        # c1 = yellow
  sw $t1, 0($t3)

  la $t3, COLOR2
  li $t2, 0xFFCE55        # c2 = yellow
  sw $t2, 0($t3)


  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  jal capsule

  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
  
  jr $ra                          # return back to draw_capsule


capsule_4:

  la $t3, COLOR1
  li $t1, 0xF16838        # c1 = orange
  sw $t1, 0($t3)

  la $t3, COLOR2
  li $t2, 0xF16838        # c2 = orange
  sw $t2, 0($t3)


  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  jal capsule

  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.

  jr $ra                          # return back to draw_capsule

capsule_5:

  la $t3, COLOR1
  li $t1, 0xDBF68F        # c1 = sour apple
  sw $t1, 0($t3)

  la $t3, COLOR2
  li $t2, 0xDBF68F        # c2 = sour apple
  sw $t2, 0($t3)

  
  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  jal capsule

  lw $ra, 0($sp)                  # Restore $ra from the stack.
  addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
  
  jr $ra                          # return back to draw_capsule








####################################
##    Generic Capsule Function    ##
####################################
# Draws a capsule horizontally
# Input parameters:
# - $a0: X coordinate of the top left corner of the capsule
# - #a1: Y coordinate of the top left corner of the capsule
# - $a2: Width of half a pill
# - $a3: Height of half a pill
capsule:
  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  la $t3 CAPSULE_O
  lw $t1 0($t3)                   # getting orientation of the capsule
  
  beq $t1 $zero call_draw_horz_capsule # jump to draw_horz0 line

  li $t2 1
  
  beq $t1 $t2 call_draw_vert_capsule   # jump to draw_horz0 line

  capsule_end:

  lw $ra, 0($sp)
  addi $sp, $sp, 4                # Deallocate stack space
  
  jr $ra                          # return back to specific capsule


  call_draw_horz_capsule:
    jal draw_horz_capsule
    j capsule_end


  call_draw_vert_capsule:
    jal draw_vert_capsule   
    j capsule_end
    



draw_horz_capsule:
  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # Store the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # Store y coordinate of the curr capsule into CAPSULE_Y

  la $t3, COLOR1
  lw $t1 0($t3)

  addi $a2, $zero, 3               # Set width
  addi $a3, $zero, 3               # Set height
  
  jal draw_rect
  
  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # Store the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # Store y coordinate of the curr capsule into CAPSULE_Y

  addi $a0, $a0, 3                 # Move x position to the right

  la $t3, COLOR2    # Load the address of COLOR2
  lw $t1, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  jal draw_rect


# me doing extra things to get the pills to look **interesting**~~~

  la $t3, COLOR1     # get color 1
  lw $t1 0($t3)

  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  addi $a0 $a0 3
  li $a2 1

  jal draw_hline

  la $t3, COLOR2     # get color 2
  lw $t1 0($t3)

  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  addi $a0 $a0 2
  addi $a1 $a1 2

  jal draw_hline

  # end of doing ~~~extra things~~~~

  lw $ra, 0($sp)
  addi $sp, $sp, 4                # Deallocate stack space
  
  jr $ra                          # return back to calling func



  


draw_vert_capsule:
  addi $sp $sp -4                 # push ra onto stack
  sw $ra 0($sp)

  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # Store the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # Store y coordinate of the curr capsule into CAPSULE_Y

  la $t3, COLOR2
  lw $t1 0($t3)

  addi $a2, $zero, 3               # Set width
  addi $a3, $zero, 3               # Set height

  jal draw_rect        # draw the bottom of the pill
  
  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # Store the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # Store y coordinate of the curr capsule into CAPSULE_Y

  addi $a1, $a1, -3                 # Move y position upwards by 3

  la $t3, COLOR1       # Load the address of COLOR1 bc we are drawing the top half now
  lw $t1, 0($t3)       # get the color 1

  jal draw_rect


  # me doing extra things to get the pills to look **interesting**~~~

  la $t3, COLOR2     # get color 2
  lw $t1 0($t3)

  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  addi $a1 $a1 -1
  li $a2 1

  jal draw_hline

  la $t3, COLOR1     # get color 1
  lw $t1 0($t3)

  la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  addi $a0 $a0 2

  jal draw_hline

  # end of doing ~~~extra things~~~~

  lw $ra, 0($sp)
  addi $sp, $sp, 4                # Deallocate stack space
  
  jr $ra                          # return back to specific capsule


  



####################################
##  The Bottle Drawing Function   ##
####################################
draw_bottle:

  # drawing bottle head
    addi $t1 $t1 0xF3F6EB     # $t1 = transparent color
    
    addi $sp, $sp, -4                # Move the stack pointer to an empty location
    sw $ra, 0($sp)                  # Store $ra on the stack for safe keeping.
    
    addi $a0 $zero 24        # setting the x pos of line
    addi $a1 $zero 9        # setting the y pos of line
    addi $a2 $zero 17       # setting width of the line
    jal draw_hline

    li $t1, 0xF3F6EB        # $t1 = white, for bottle color
    addi $a2 $zero 4       # setting width of the line
    jal draw_hline          # drawing top left lip

    addi $a0 $zero 36        # setting the x pos of line
    jal draw_hline          # drawing top right lip

    addi $a0 $zero 23        # setting the x pos of line
    addi $a2 $zero 4       # setting height of the line
    jal draw_vline       # drawing the left bottle lip wall

    addi $a2 $zero 17      # setting height of the line
    add $a0 $a0 $a2
    addi $a2 $zero 3
    jal draw_vline       # drawing the right bottle lip wall

    addi $a0 $zero 24
    add $a1 $a1 $a2
    addi $a2 $zero 5
    jal draw_hline       # drawing the left bottom lip tucking in

    addi $a0 $a0 12
    jal draw_hline       # drawing the right bottom lip tucking in

    addi $a0 $zero 28    # starting x position of the bottle (24) + 5
    addi $a1 $zero 12    # starting y position of the bottle (10) + 3
    addi $a2 $zero 4     # setting length to 3
    jal draw_vline       # drawing the left wall of neck

    addi $a0 $zero 35    # starting x position of the bottle (23) + 16 - 5
    jal draw_vline       # drawing the right wall of neck

    addi $a0 $zero 19    # starting x position of the bottle (23) - 3
    addi $a1 $zero 15    # starting y position of the bottle (10) + 6
    addi $a2 $zero 9     # setting length to 9
    jal draw_hline       # drawing the left shoulder

    addi $a0 $zero 36    # starting x position of the bottle (23) - 3
    addi $a1 $zero 15    # starting y position of the bottle (10) + 6
    jal draw_hline       # drawing the right shoulder

    addi $a0 $zero 19    # starting x position of the bottle
    addi $a2 $zero 41     # setting length to 40
    jal draw_vline       # drawing the left wall of bottle

    addi $a0 $zero 44    # starting x position of the bottle
    jal draw_vline       # drawing the right wall of bottle

    addi $a0 $zero 20    # starting x position of the bottle
    addi $a1 $zero 55    # starting y position of the bottle 
    addi $a2 $zero 24     # setting length to 20
    jal draw_hline       # drawing the bottom

    addi $a0 $zero 20    # coloring bottle background
    addi $a1 $zero 16    # 

    addi $a2 $zero 24
    addi $a3 $zero 39

    li $t1, 0x266533        # $t1 = green (bg)

    jal draw_rect
    

    lw $ra, 0($sp)                  # Restore $ra from the stack.
    addi $sp, $sp, 4                # move the stack pointer to the current top of the stack.
    
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












## The vertical line drawing function ## WORKS!!
# Input parameters:
# - $a0: X coordinate of the start of the line
# - #a1: Y coordinate of the start of the line
# - $a2: Length of the line
draw_vline:
  add $t5 $zero $zero               # setting the counter to 0
  
  addi $t3 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t4 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t3 $a0                     # set the number of rows to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t4 $a1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1                          

  add $t7 $t0 $v0                 # setting the horizontal offset
  add $t7 $t7 $v1                 # setting the vertical offset

  vpixel_draw_start:                 # the starting label for the pixel drawing loop
    sw $t1, 0( $t7 )                # paint the current bitmap location.
    
    addi $t5 $t5 1                  # add 1 to the counter
    addi $t7, $t7, 256                # move to the next pixel in the row.
    beq $t5, $a2, vpixel_draw_end     # break out of the loop if you hit the final pixel
    j vpixel_draw_start              # otherwise, jump to the top of the loop
  vpixel_draw_end:                   # the label for the end of the pixel drawing loop
  jr $ra 




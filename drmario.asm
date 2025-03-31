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
    .word 0x10010008

# The address of the orientation grid for keeping track of capsule halves
ORI_GRID:
    .space 16384


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

    jal ycollision  # sets t0 to 0 if there is a vertical collision

    beq $t0 $zero handle_collision
    j draw_new_capsule_end

    handle_collision:

      li $a0 20
      li $a1 16
      li $a2 24
      li $a3 39

      jal copy_grid

      # kate
      li $a0 20         # X coord of top left corner of dark green rectangle
      li $a1 16         # Y coord of top left corner of dark green rectangle
      li $a2 0xDBF68F       # check for sour apple
      jal remove_rows
      
      li $a0 20
      li $a1 16
      li $a2 0xDBF68F
      jal remove_columns
      
      li $a0 20
      li $a1 16
      li $a2 0xF16838       # check for orange
      jal remove_rows
      
      li $a0 20
      li $a1 16
      li $a2 0xF16838
      jal remove_columns
      
      li $a0 20
      li $a1 16
      li $a2 0xFFCE55       # check for yellow
      jal remove_rows
      
      li $a0 20
      li $a1 16
      li $a2 0xFFCE55
      jal remove_columns

      beq $t0 $zero collision_end
      
      li $a0 20
      li $a1 16
      li $a2 24
      li $a3 39

      jal handle_drop

      j handle_collision

      
      collision_end:

      jal draw_start_capsule  # start the next capsule after everything is done
      

    draw_new_capsule_end:

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
      li $t0 0
      j y_collision_return
    
    set_y_collision_end:
      li $t0 1                    # 1 in t1 = no collision
     
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
  


############################
##  Handle Drop Function  ##
############################
# (a0, a1) starting coordinates, a2 width, a3 length, returns a 0 in t9 if there was no drop made, 1 if there was
handle_drop:
  add $t6, $a1, $zero         # Store initial y-coordinate (16)
  addi $a1, $zero, 49         # Set start y-coordinate
  
  drop_row_start:
    push ($ra)
    push ($a0)
    push ($a1)
    push ($t6)

    jal drop_row

    pop ($t6)
    pop ($a1)
    pop ($a0)
    pop ($ra)

    addi $t5, $t5, 1         # Increment loop counter (optional)
    addi $a1, $a1, -3        # Decrease y-coordinate by 3

    bne $a1, 16, drop_row_start  # Keep looping until a1 reaches 16

  drop_row_end:
    jr $ra




# given the starting coordinate of a row (a0, a1), and length (a2), drop everything in the row 
# down by one capsule area if the area below them is background color (and their half allows them to)
drop_row:
  li $t9 0
  
  push ($ra)

  # counter initialization
  li $s5 0

  addi $t3 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t4 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t3 $a0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t4 $a1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  la $t6, ADDR_DSPL                    # Load base address of playfield
  lw $t0 0($t6)

  la $t5, ORI_GRID                    # Load base address of orientation field

  # playfield
  add $s7, $t0, $v0                    # Source: base + X offset
  add $s7, $s7, $v1                    # Source: base + Y offset

  # orientation grid
  add $t8, $t5, $v0                    # Source: base + X offset
  add $t8, $t8, $v1                    # Source: base + Y offset


  block_drop_start:
    push ($a0)
    push ($a1)
    push ($a2)

    li $t3 0x266533                      # loading in background color to do checks
    
    lw $t5 0($s7)                      # getting color stored at the current block to see if it's colored

    beq $t5 $t3 increment_next         # if it's background colored, move to next area

    lw $t4 0($t8)                      # checking orientation value (stored in $t4)
    li $t5 -1                          # checking to see if it's a virus using t5
    beq $t5 $t4 increment_next         # if they are equal, then it's virus and we move to next block

    # else we are at a capsule and we need to check whether it's free below

    addi $t6 $s7 768                   # getting location of the block below

    li $t0 0xffffff

    lw $t5 0($t6)                      # getting color stored there
    
    beq $t5 $t3 check_half             # if the bottom has space, then check their orientation for half
    j increment_next                   # else increment to the next block

    check_half:
      # li $t5 1
      # beq $t4 $t5 drop_lone            # if it has no other half, drop itself

      # li $t5 2
      # beq $t4 $t5 drop_top            # its other half is on top, so we just drop

      # li $t5 4
      # beq $t4 $t5 drop_right            # its other half is to the right, then we need to check whether they have a free space below too


      drop_lone:

        lw $t1 0($s7)                 # getting color stored there again to move it down
        add $a0 $a0 $s5               # getting the current x index

        addi $a1 $a1 3                # move down by a capsule

        li $a2 3                      # setting size of cube to draw
        li $a3 3

        push ($a0)
        push ($a1)

        jal draw_rect

        pop ($a1)
        pop ($a0)

        li $t1 0x266533               # background color
        addi $a1 $a1 -3               # move back to original block location to draw it to the background

        push ($a0)
        push ($a1)

        jal draw_rect

        pop ($a1)
        pop ($a0)

        # taking care of orientation drops too

        addi $t2 $t8 768              # moving down orientation graph by 3 pixels
        li $t3 1

        sw $t3 0($t2)                 # load in the value of 1 at the new location where the capsule block is
        sw $zero 0($t8)               # load in a zero at the original location

        li $t9 1                      # change t9 to 1, meaning that we've a drop
        
        j increment_next


      # drop_right: # reminder: we are at the left half of this capsule
      #   # need to do another check to see if other half has space below
      #   add $t4 $s7 780               # getting location of the space below the right half
      #   lw $t2 0($t4)                 # getting the color at the location

      #   bne $t2 $t3 increment_next    # if it's not available, then we increment next and we don't have to 
      #   # worry about handling the left half again because it won't go through the first if branch

      #   # else: drop both down
      #   lw $t1 0($s7)                 # getting color of left half
      #   addi $t2 $t7 12               # getting location of right half
      #   lw $t3 0($t2)                 # getting color of right half

      #   add $a0 $a0 $s5               # getting the x coordinate of the left capsule
        
      #   addi $a1 $a1 3                # move down by a block

      #   li $a2 3                      # setting size of cube to draw
      #   li $a3 3

      #   push ($a0)
      #   push ($a1)

      #   jal draw_rect                 # draw the left half in the new place

      #   pop ($a1)
      #   pop ($a0)
        
      #   add $t1 $zero $t3             # changing t1 to the color of the right half
      #   add $a0 $a0 3                 # getting the x coordinate of the right capsule
      #   # y coord should be the same

      #   push ($a0)
      #   push ($a1)

      #   jal draw_rect                 # draw the right half of the capsule

      #   pop ($a1)
      #   pop ($a0)

      #   add $a0 $a0 -3                # moving back to the original coordinate to draw background color over
      #   addi $a1 $a1 -3 

      #   li $a2 6                      # changing width to 6
      #   li $t1 0x266533               # background color

      #   push ($a0)
      #   push ($a1)

      #   jal draw_rect                 # drawing over the background

      #   pop ($a1)
      #   pop ($a0)

      #    # taking care of orientation drops

      #   addi $t2 $t8 768              # moving down orientation offset by 3 pixels
      #   li $t3 4                      # setting it as 4 because the half is on the right

      #   sw $t3 0($t2)                 # save the value of 4 at the new location where the capsule block is
      #   sw $zero 0($t8)               # save a zero at the original location

      #   addi $t2 $t8 12               # moving to the right by 3 pixels to set the original location of the right half to 0 as well
      #   sw $zero 0($t2)

      #   addi $t2 $t8 780              # moving to the bottom of the right half
      #   li $t3 16                     # loading in 16 because the other half is on the left
      #   sw $t3 0($t2)                 # saving 16 at the new location of the right half

      #   li $t9 1                      # change t9 to 1, meaning that we've a drop

      #   j increment_next

      # drop_top:
        
      #   lw $t4 0($s7)                 # getting color stored there again to move it down
      #   addi $t3 $s7 -768             # getting location of friend
      #   lw $t1 0($t3)                 # getting color of other half (setting it to t1 so that we can draw immediately)

      #   add $a0 $a0 $s5               # getting the current x index

      #   li $a2 3                      # setting size of cube to draw
      #   li $a3 3

      #   push ($a0)
      #   push ($a1)

      #   jal draw_rect                 # drawing the top half in the current pixel

      #   pop ($a1)
      #   pop ($a0)

      #   add $t1 $zero $t4             # setting the color to draw as the bottom half color
      #   add $a1 $a1 3                 # moving to the block area below

      #   push ($a0)
      #   push ($a1)

      #   jal draw_rect                 # drawing the bottom half in the current pixel

      #   pop ($a1)
      #   pop ($a0)

      #   add $a1 $a1 -6                # moving to the location of the top half
      #   li $t1 0x266533               # load in background color

      #   push ($a0)
      #   push ($a1)
        
      #   jal draw_rect                 # drawing the top half location to background color

      #   pop ($a1)
      #   pop ($a0)

      #   # taking care of orientation drops too

      #   addi $t2 $t8 768              # moving down orientation offset by 3 pixels
      #   li $t3 2

      #   sw $t3 0($t2)                 # load in the value of 2 at the new location where the bottom capsule block is

      #   addi $t2 $t8 768              # moving up the orientation offset by 3 pixels to set it to zero
      #   sw $zero 0($t2)               # saving value of zero at the original spot of the top half 

      #   li $t3 8
      #   sw $t3 0($t8)                 # save 8 in the new location where the top capsule is

      #   li $t9 1                      # change t9 to 1, meaning that we've a drop

      #   j increment_next


    increment_next:
      
    addi $s5 $s5 3                  # add 3 to the counter
    addi $s7 $s7 12                 # add 12 to playfield offset
    addi $t8 $t8 12                 # add 12 to orientation offset
    
    pop ($a2)
    pop ($a1)
    pop ($a0)

    beq $s5 $a2 block_drop_end
    j block_drop_start
  
  block_drop_end:
    pop ($ra)
    jr $ra








##########################
##  Copy Grid Function  ##
##########################
# Input parameters:
# - $a0: X coordinate of the top left corner of the rectangle
# - #a1: Y coordinate of the top left corner of the rectangle
# - $a2: Width of the rectangle to copy
# - $a3: Height of the rectangle to copy
copy_grid:
  add $t5 $zero $zero       # setting the loop variable to 0
  copy_line_start:
    push ($ra)
    push ($t5)
    push ($a0)
    push ($a1)

    jal copy_line

    pop ($a1)
    pop ($a0)
    pop ($t5)
    pop ($ra)

    addi $t5 $t5 1                  # increment loop var by 1 after drawing one line
    addi $a1 $a1 1                  # increment y coordinate after each line
    
    beq $t5, $a3, copy_line_end
    j copy_line_start

  copy_line_end:
  
  jr $ra 
    


# Copy grid helper
copy_line:
  add $t5 $zero $zero               # setting the counter to 0

  addi $t3 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t4 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate

  multu $t3 $a0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  
  multu $t4 $a1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1

  lw $t6, ADDR_DSPL                    # Load base address of source grid 

  lw $t9, ADD_GRID

  # Compute starting positions
  add $t7, $t6, $v0                    # Source: base + X offset
  add $t7, $t7, $v1                    # Source: base + Y offset

  add $t8, $t9, $v0                    # Destination: base + X offset
  add $t8, $t8, $v1                    # Destination: base + Y offset


  pixel_copy_start:         
    lw $t1 0( $t7 )
    sw $t1 0( $t8 )                # paint the current current location to 
    
    addi $t5 $t5 1                  # add 1 to the counter
    addi $t7, $t7, 4                # move to the next pixel in the row for playing field
    addi $t8, $t8, 4                # move to the next pixel in the row for additional grid
    
    beq $t5, $a2, pixel_copy_end     # break out of the loop if you hit the final pixel
    j pixel_copy_start              # otherwise, jump to the top of the loop
  pixel_copy_end:                   # the label for the end of the pixel drawing loop
  
  jr $ra 





#######################################
##     The Row Removal Function      ##
#######################################
# Input parameters:
# - $a0: X coordinate of the top left corner of the rectangle
# - $a1: Y coordinate of the top left corner of the rectangle
# - $a2: colour value to check if 4+ connected
remove_rows:
  push ($ra)
  add $t5 $zero $zero       # setting the loop variable to 0
  remove_r_start:
    push ($ra)
    push ($t5)
    push ($a0)
    push ($a1)
    push ($a2)

    jal check_row
    
    pop ($a2)
    pop ($a1)
    pop ($a0)
    pop ($t5)
    pop ($ra)

    addi $t5 $t5 1                  # increment loop var by 1 after checking one row
    addi $a1 $a1 3                  # increment y coordinate after each line (going to next capsule half location)
    
    beq $t5, 13, remove_r_end         # if t5 reached all rows (39 pixels total, 13 rows of capsule halves) (goes from 0 to 12, then add 1 so 13)
    j remove_r_start

  remove_r_end:
  # t9 should be 1 if at least one row removed
  beq $t9 1 removed_row
  j no_removed_row
  
    removed_row:
    li $t0 1        # setting t0 to 1 to signal at least one row removed
    jr $ra 
  
    no_removed_row:
    li $t0 0          # no removed row, set t0 to 0
    jr $ra
  
  
check_row:
  push ($ra)
  add $t5 $zero $zero               # setting the counter to 0
  
  addi $t3 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
  addi $t4 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate
  multu $t3 $a0                     # set the number of columns to skip through multiplication (X coordinate)
  mflo $v0                          
  multu $t4 $a1                     # set the number of rows to skip through multiplication (Y coordinate)
  mflo $v1
  lw $t6, ADDR_DSPL                    # Load base address of source grid 

  # Compute starting positions
  add $t7, $t6, $v0                    # Source: base + X offset
  add $t7, $t7, $v1                    # Source: base + Y offset
  
  # t7 now holds memory location of rectangle

    # 20         # X coordinate of the top left corner of the rectangle
    # 16         # Y coordinate of the top left corner of the rectangle
    # 24         # Width of the rectangle to copy
    # 39         # Height of the rectangle to copy
    
  add $t6 $zero $zero       # setting counter for 4+ connected check (increments every time it sees the colour)
  
  # RIGHT NOW: t7 is memory address of green box on display grid (top left corner); t6 is 4+ check; t5 is loop variable; 
  # a0 is X coordinate of top left corner of rectangle (20); a1 is Y coordinate (16); a2 is colour hex code to check
  
  row_loop:
    beq $t5 8 row_loop_end       # end loop if reached end of row
  
    # not at end; keep checking
    lw $t1 0($t7)             # t1 stores colour at t7 position
  
    bne $t1 $a2 continue_loop_no_common       # branch if current pixel colour is NOT equal to colour we're checking
    addi $t6 $t6 1                # increment bc we found a pixel w/ colour in common
      beq $t6 1 save_address        # save location of first pixel in common in case we need to erase
    j continue_loop_common
    
  # RIGHT NOW: t1, t5, t6, t7, a0, a1, a2 occupied
  
  save_address:
    # RIGHT NOW: t7 stores current memory address on display grid of first pixel in common
    # t5 stores what current loop iteration we're on (starting from 0-7) ; a1 stores what y coordinate we're on
    # a0 stores X coordinate of top left corner of green rectangle
    # to get X coordinate of block we want to save, add (3*t5) to a0
    
    add $t2 $zero $t5       # t2 = t5
    addi $t3 $zero 3        # t3 = 3
    multu $t2 $t3           # t2 * t3
    mflo $t2                # t2 stores 3*(t5)
    add $t2 $t2 $a0         # t2 = t2 + a0          # now t2 storing X coordinate of block we want to save
    
    j continue_loop_common
  
  continue_loop_no_common: 
    # if t6 already >= 4, then go to remove_row_start           # OMFGGG THIS WAS THE BUGGGGGG
    addi $t3 $t6 -3         # t3 = t6 - 3
    bgtz $t3 remove_row_start
    
    # else
    add $t6 $zero $zero         # reset t6 to 0 since found one not in common
    addi $t5 $t5 1            # increment t5 for next check in row
    addi $t7 $t7 12           # move to next capsule location (3 * 4 spots in memory)
    j row_loop
  
  continue_loop_common:
    addi $t5 $t5 1            # increment t5 for next check in row
    addi $t7 $t7 12           # move to next capsule location (3 * 4 spots in memory)
    j row_loop
  
  
  row_loop_end:       # checked entire row
    # t6 stores how many capsule halves in that row had the same colour
    
    addi $t3 $t6 -3         # t3 = t6 - 3
    # if row not deletable, t3 <= 0; if row deletable, t3 > 0
    bgtz $t3 remove_row_start         # branches to remove_row_start if deletable
    # else, jump to end
    j remove_row_end
    
    remove_row_start:
    #t2 (x) and a1 (y) store position of first block in common
    
    # In rectangle drawing function (draw_rect):
        # - $a0: X coordinate of the top left corner of the rectangle
        # - #a1: Y coordinate of the top left corner of the rectangle
        # - $a2: Width of the rectangle
        # - $a3: Height of the rectangle
        ###### also need t0 to store base address of grid and t1 to store colour            # include in input parameters later!!
            # both t0 and t1 should be okay to modify here
        
        lw $t0 ADDR_DSPL        # removing in display grid
        li $t1 0x266533         # dark green colour
        
    
    add $a0 $zero $t2       # a0 = t2 (x coordinate of first pixel in common)
    # a1 already has what we need (y coordinate of first pixel in common)
    # a2 - width of rectangle is 3*t6
    # a3 - height is just 3 (height of capsule half)
    addi $t3 $zero 3
    multu $t3 $t6           # 3 * t6
    mflo $a2                # a2 = 3 * t6
    addi $a3 $zero 3        # a3 = 3        # height of rectangle
    
    push ($a0)
    push ($a1)
    push ($a2)
    push ($a3)
    
    jal draw_rect           # call draw_rect to erase row
    
    pop ($a0)
    pop ($a1)
    pop ($a2)
    pop ($a3)
    
    li $t9 1                # setting t9 to 1 to signal at least one row removed
    
    remove_row_end:
    pop ($ra)
    jr $ra






#######################################
##    The Column Removal Function    ##
#######################################
# Input parameters:
# - $a0: X coordinate of the top left corner of the rectangle
# - $a1: Y coordinate of the top left corner of the rectangle
# - $a2: colour value to check if 4+ connected
remove_columns:
  push ($ra)
  add $t5 $zero $zero       # setting the loop variable to 0
  remove_c_start:
    push ($ra)
    push ($t5)
    push ($a0)
    push ($a1)
    push ($a2)

    jal check_column
    
    pop ($a2)
    pop ($a1)
    pop ($a0)
    pop ($t5)
    pop ($ra)
    
    addi $t5 $t5 1                  # increment loop var by 1 after checking one column
    addi $a0 $a0 3                  # increment x coordinate after column check (going to next capsule half location)
    
    beq $t5, 8, remove_c_end         # if t5 reached all columns (8 columns of capsule halves) (goes from 0 to 7, then add 1 so 8)
    j remove_c_start
    
    remove_c_end:
      # t9 should be 1 if at least one column removed
      beq $t9 1 removed_col
      j no_removed_col
  
    removed_col:
    li $t0 1        # setting t0 to 1 to signal at least one column removed
    jr $ra 
  
    no_removed_col:
    li $t0 0          # no removed column, set t0 to 0
    jr $ra
    
  
  check_column:
    push ($ra)
    add $t5 $zero $zero               # setting the counter to 0
  
    addi $t3 $zero 4                  # store constant 4 in t3 so we can do multiplication with the x coordinate
    addi $t4 $zero 256                # store constant 256 in t4 so we can do multiplication with the y coordinate
    multu $t3 $a0                     # set the number of columns to skip through multiplication (X coordinate)
    mflo $v0                          
    multu $t4 $a1                     # set the number of rows to skip through multiplication (Y coordinate)
    mflo $v1
    lw $t6, ADD_GRID                    # Load base address of additional grid 

    # Compute starting positions
    add $t7, $t6, $v0                    # Source: base + X offset
    add $t7, $t7, $v1                    # Source: base + Y offset
  
    # t7 now holds memory location of rectangle (in additional grid)
    
    add $t6 $zero $zero       # setting counter for 4+ connected check (increments every time it sees the colour)
  
    # RIGHT NOW: t7 is memory address of green box on display grid (top left corner); t6 is 4+ check; t5 is loop variable; 
    # a0 is X coordinate of top left corner of rectangle (20); a1 is Y coordinate (16); a2 is colour hex code to check

    column_loop:
      beq $t5 13 col_loop_end       # end loop if reached end of column
  
      # not at end; keep checking
      lw $t1 0($t7)             # t1 stores colour at t7 position
  
      bne $t1 $a2 continue_loop_no_common_col       # branch if current pixel colour is NOT equal to colour we're checking
      addi $t6 $t6 1                # increment bc we found a pixel w/ colour in common
        beq $t6 1 save_address_col        # save location of first pixel in common in case we need to erase
      j continue_loop_common_col
    
      # RIGHT NOW: t1, t5, t6, t7, a0, a1, a2 occupied
        
      
      save_address_col:
        # RIGHT NOW: t7 stores current memory address on additional grid of first pixel in common
        # t5 stores what current loop iteration we're on (starting from 0-12) ; a0 stores what x coordinate we're on
        # a1 stores Y coordinate of top left corner of green rectangle
        # to get Y coordinate of block we want to save, (3*t5) + a1
    
        add $t2 $zero $t5       # t2 = t5
        addi $t3 $zero 3        # t3 = 3
        multu $t2 $t3           # t2 * t3
        mflo $t2                # t2 stores 3*(t5)
        add $t2 $t2 $a1         # t2 = t2 + a1          # now t2 storing Y coordinate of block we want to save
    
        j continue_loop_common_col
       
      continue_loop_no_common_col: 
        # if t6 already >= 4, then go to remove_col_start
        addi $t3 $t6 -3         # t3 = t6 - 3
        bgtz $t3 remove_col_start
    
        # else
        add $t6 $zero $zero         # reset t6 to 0 since found one not in common
        addi $t5 $t5 1            # increment t5 for next check in column
        addi $t7 $t7 768           # move to next capsule location down (3 * 256 spots in memory)
        j column_loop
    
      continue_loop_common_col:
        addi $t5 $t5 1            # increment t5 for next check in column
        addi $t7 $t7 768           # move to next capsule location down (3 * 256 spots in memory)
        j column_loop
  
  
      col_loop_end:       # checked entire column
        # t6 stores how many capsule halves in that column had the same colour
    
        addi $t3 $t6 -3         # t3 = t6 - 3
        # if column not deletable, t3 <= 0; if column deletable, t3 > 0
        bgtz $t3 remove_col_start         # branches to remove_col_start if deletable
        # else, jump to end
        j remove_col_end
  
  
      remove_col_start:
        #t2 (x) and a1 (y) store position of first block in common
    
    # In rectangle drawing function (draw_rect):
        # - $a0: X coordinate of the top left corner of the rectangle
        # - #a1: Y coordinate of the top left corner of the rectangle
        # - $a2: Width of the rectangle
        # - $a3: Height of the rectangle
        ###### also need t0 to store base address of grid and t1 to store colour            # include in input parameters later!!
            # both t0 and t1 should be okay to modify here
        
        lw $t0 ADDR_DSPL        # removing in display grid
        li $t1 0x266533         # dark green colour
        
    # a0 already has what we need (x coordinate of first pixel in common)
    add $a1 $zero $t2       # a1 = t2 (y coordinate of first pixel in common)
    # a2 - width of rectangle is 3
    # a3 - height of rectangle is 3*t6
    addi $a2 $zero 3        # a2 = 3
    addi $t3 $zero 3
    multu $t3 $t6           # 3 * t6
    mflo $a3                # a3 = 3 * t6
    
    push ($a0)
    push ($a1)
    push ($a2)
    push ($a3)
    
    jal draw_rect           # call draw_rect to erase column
    
    pop ($a0)
    pop ($a1)
    pop ($a2)
    pop ($a3)
    
    li $t9 1                # setting t9 to 1 to signal at least one column removed
    
    remove_col_end:
    pop ($ra)
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

  # setting horizontal orientation
  li $a2 0 
  la $t3, CAPSULE_O               # loading orientation address
  sw $a2 0($t3)                   # writing orientation to be default horizontal

  
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

  # la $t3, COLOR1     # get color 1
  # lw $t1 0($t3)

  # la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  # lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  # la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  # lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  # addi $a0 $a0 3
  # li $a2 1

  # jal draw_hline

  # la $t3, COLOR2     # get color 2
  # lw $t1 0($t3)

  # la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  # lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  # la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  # lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  # addi $a0 $a0 2
  # addi $a1 $a1 2

  # jal draw_hline

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

  # la $t3, COLOR2     # get color 2
  # lw $t1 0($t3)

  # la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  # lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  # la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  # lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  # addi $a1 $a1 -1
  # li $a2 1

  # jal draw_hline

  # la $t3, COLOR1     # get color 1
  # lw $t1 0($t3)

  # la $t3, CAPSULE_X    # Load the address of CAPSULE_X
  # lw $a0, 0($t3)       # get the x coordinate of the curr capsule into CAPSULE_X

  # la $t3, CAPSULE_Y    # Load the address of CAPSULE_X
  # lw $a1, 0($t3)       # get y coordinate of the curr capsule into CAPSULE_Y

  # addi $a0 $a0 2

  # jal draw_hline

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




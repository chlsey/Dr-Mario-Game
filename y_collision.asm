

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
    jal set_y_collision
    
    h_y_col_check2:             # this one checking if second half of pill collides with anything
    addi $t7 $t7 12             # moving to ghost location of second half of pill
    lw $t2 0($t7)               # loading t2 with next pixel location (of second half)
    
    beq $t3 $t2 set_y_collision_end   # see if second half has collision ; if equal, then no collision; if not equal, then collision
    
    jal set_y_collision
  
  
  y_v_collision:            # in vertical orientation, checking if down movement causes collision
    addi $t7 $t7 768                 # moving to location of potential next move
    lw $t2 0($t7)                   # loading t2 with the next pixel location

    li $t3 0x266533                 # kate - dark green background
    beq $t3 $t2 set_y_collision_end   # no collision!

    jal set_y_collision               # else yes collision :(
  
  
    set_y_collision:
      li $t1 0
      jal y_collision_return
    
    set_y_collision_end:
      li $t1 1                    # 1 in t1 = no collision
     
    y_collision_return:
      lw $ra 0($sp)                     # get $ra back
      addi $sp $sp 4

      jr $ra





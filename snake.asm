# Ronen Orland and Julian Linkhauer
# Snake Midterm Project
# Date Created: 2/23/17

.data 
  
# The board. Every * indicates an LED turned on as a wall.
  .ascii  "*****************************************************  *********"	# Top border
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                 ***************              *"
  .ascii  "*                                 *                            *"
  .ascii  "*                                 * *************              *"
  .ascii  "*                                 * *                          *"
  .ascii  "*                                 * *                          *"
  .ascii  "*                                 * *                          *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                        **************        *"
  .ascii  "*                                        *            *        *"
  .ascii  "*                                        *            *        *"
  .ascii  "*                                        *            *        *"
  .ascii  "*                                        *            *        *"
  .ascii  "*                                                ******     *  *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                       ********************   *"
  .ascii  "*                                       *                  *   *"
  .ascii  "*                                       *   ************   *   *"
  .ascii  "*                                           *          *   *   *"
  .ascii  "*                                           *          *   *   *"
  .ascii  "*                                       *   *          *   *   *"
  .ascii  "*                                       *   *          *   *   *"
  .ascii  "*                                       *   *          *   *   *"
  .ascii  "*                                       *   ************   *   *"
  .ascii  "*                                       *                  *   *"
  .ascii  "*                                       *                  *   *"
  .ascii  "*                                       ********************   *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                                                              *"
  .ascii  "*                     * *                                      *"
  .ascii  "*                     * *                                      *"
  .ascii  "*                     * *                                      *"
  .ascii  "*                     * *                                      *"
  .ascii  "*********************** *                           ************"
  .ascii  "                        *                           *           "
  .ascii  "*************************                           *  *********"
  .ascii  "*                                                   *  *       *"
  .ascii  "*                                                   *  *       *"
  .ascii  "*                                                   *  *       *"
  .ascii  "*                                                   *  *       *"
  .ascii  "*                                                   *  *       *"
  .ascii  "*                                                   *          *"
  .ascii  "*                                                   *          *"
  .ascii  "*                                                   *  *       *"
  .ascii  "*                                                   *  *       *"
  .asciiz "*****************************************************  *********"	# Bottom border, null terminated
  
#=================================================================================================================
#=========                                          Program                                         ==============
#=================================================================================================================

#*****
.text
#*****

#**************************************************************************************

# void _buildWall()
	#   fills LED board with walls based on string stored in memory
	#   uses _setLED in loop
	#
	# arguments: 
	# trashes:
	# returns: none
	#
_buildWall:
	la $s0, 0x10010000		# Load address of wall string
  	addi $a0, $a0, 0		# Start x at 0
  	addi $a1, $a1, 0		# Start y at 0
  	addi $a2, $a2, 1		# Set color to red
  
  LOOP_WALL:
  	lb $t0, 0($s0)			# Load next char to inspect
  	beq $t0, 0x2a, JUMP_WALL	
  	beq $t0, 0x00, _buildSnake	# Wall sequence is over, go to build snake
  	addi $a0, $a0, 1		# Increment x
  	beq $a0, 64, NEWLINE		# If at end of row, go to next line
  	addi $s0, $s0, 1		# Increment string address
  	j LOOP_WALL			
  
  JUMP_WALL: 
  	jal _setLED			
  	addi $a0, $a0, 1		# Increment x
  	beq $a0, 64, NEWLINE		# If end of row, go to next line
  	addi $s0, $s0, 1		# Else, increment string address
  	j LOOP_WALL
	
  NEWLINE:
  	add $a0, $zero, $zero		# Reset x to 0
  	addi $a1, $a1, 1		# Increment y
  	addi $s0, $s0, 1		# Increment string address
  	j LOOP_WALL
	
#**************************************************************************************	
	
# void _buildSnake
	# Initializes snake head, body, and tail
	# Head = (11,31)
	# Body = [10 to 5,31]
	# Tail = (4,31)
	#
	# arguments: 
	# trashes: 
	# returns: none
	#
_buildSnake:
	
#**************************************************************************************	
	
# int _populateFrogs()
	# Sets random LED to green for a frog
	# Does not change to green if LED is part of wall, snake, or another frog
	# Does 32 attempts, but doesn't necessarily produce 32 frogs
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color 
	# trashes: $t0-$t1
	# returns: $s1 is # of frogs populated by end
	#
_populateFrogs:
	li	$a2, 3			# Set color to green
	li	$t0, 0			# t0 = attempt counter, loop stops at 32
 
  LOOP_FROG:
	beq	$t0, 32, EXIT		# If 32 attempts have been made, exit (change to start game)
	
	li	$v0, 42			# Generate random int range syscall
	li	$a1, 64			# Set upper limit to 64
	syscall				# Generate random Y value
	add	$t1, $a0, $0		# Store Y value in t1
	syscall				# Generate random X value
	add	$a1, $t1, $0		# Restore Y value in a1 for _getLED call
	
  	jal	_getLED			# Get value of LED at loc, stored in $v0
	addi	$t0, $t0, 1		# increment attempt counter
	bne	$v0, $zero, LOOP_FROG	# If LED is already taken, do another attempt
	jal	_setLED			# Else, set current position to be a frog
	addi	$s1, $s1, 1		# Increment frog counter
	j	LOOP_FROG		# Loop again
  
#**************************************************************************************

# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=yellow, 3=green
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color
	# trashes:   $t0-$t3
	# returns:   none
	#
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008 # base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra
	
#**************************************************************************************
  
	# int _getLED(int x, int y)
	#   returns the value of the LED at position (x,y)
	#
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2 or 3)
	#
_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra

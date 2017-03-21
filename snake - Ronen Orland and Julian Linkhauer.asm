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
  .ascii  "*                                           ************   *   *"
  .ascii  "*                                           ************   *   *"
  .ascii  "*                                       *   ************   *   *"
  .ascii  "*                                       *   ************   *   *"
  .ascii  "*                                       *   ************   *   *"
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
  
  _snake:	.space 80	# Allocate space to store snake
  win_message:		.asciiz	"Congratulations, you win!\n"	# Message displayed upon winning
  lose_message:		.asciiz "Game over, you lose!\n"	# Message displayed upon losing
  score_message:	.asciiz "Your final score is: "		# Score display message
  time_message:		.asciiz "\nYour time played is: "	# Time display message
  unit_message:		.asciiz "ms"				# Show units of time
  
#=================================================================================================================
#===========                                          Program                                          ===========
#=================================================================================================================

.text

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
	# arguments: $s0 is snake location
	# trashes: $t4
	# returns: none
	#
_buildSnake:
	li	$a2, 2			# Set color to yellow for snake
	la	$s0, _snake		# Load address of snake 
	addi	$s0, $s0, 1		# Realign memory address
	move	$s5, $s0		# Set tail pointer
	addi	$t4, $0, 0x041f		# t4 = value of location of tail beginning
	sh	$t4, ($s0)		# store location of tail
	lb	$a0, 1($s0)		# get x loc for tail
	lb	$a1, ($s0)		# get y loc for tail
	jal	_setLED			# set color
	
  LOOP_buildSnake:
  	addi	$t5, $t5, 1		# Incrementer for build loop
	beq	$t5, 8, _populateFrogs	# if fully built, populate frogs
	addi	$s0, $s0, 2		# Increment address
	addi	$t4, $t4, 0x100		# Increment X loc 
	sh	$t4, ($s0)		# store location of tail
	lb	$a0, 1($s0)		# get x loc for current segment
	lb	$a1, ($s0)		# get y loc for current segment
	jal	_setLED			# set color
	j	LOOP_buildSnake		# Loop again
	
#**************************************************************************************	
	
# int _populateFrogs()
	# Sets random LED to green for a frog
	# Does not change to green if LED is part of wall, snake, or another frog
	# Does 32 attempts, but doesn't necessarily produce 32 frogs
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color 
	# trashes: $t4-$t5
	# returns: $s1 is # of frogs populated by end
	#
_populateFrogs:
	move	$s4, $s0		# Set head pointer
	li	$a2, 3			# Set color to green
	li	$t4, 0			# t0 = attempt counter, loop stops at 32
			
	li	$s6, 0xE3		# Set initial direction to right
	sb	$s6, 0xFFFF0004
 
  LOOP_FROG:
	beq	$t4, 32, GAME_START	# If 32 attempts have been made, ready to start game
	
	li	$v0, 42			# Generate random int range syscall
	li	$a1, 64			# Set upper limit to 64
	syscall				# Generate random Y value
	add	$t5, $a0, $0		# Store Y value in t1
	syscall				# Generate random X value
	add	$a1, $t5, $0		# Restore Y value in a1 for _getLED call
	
  	jal	_getLED			# Get value of LED at loc, stored in $v0
	addi	$t4, $t4, 1		# increment attempt counter
	bne	$v0, $zero, LOOP_FROG	# If LED is already taken, do another attempt
	jal	_setLED			# Else, set current position to be a frog
	addi	$s1, $s1, 1		# Increment frog counter
	j	LOOP_FROG		# Loop again
  
#**************************************************************************************
#				Game loop starts here
#
# Variable list:
#	s0 = address of snake data
#	s1 = # of frogs on board
#	s2 = frogs eaten (score)
#	s3 = game start time
#	s4 = head pointer
#	s5 = tail pointer
#	s6 = keyboard tracker/current direction
#		0 = up, 1 = right, 2 = down, 3 = left
#	s7 = previous direction
#	t8 = change_dir check
#		if == 1 and trying to change direction again, lose
#	t9 = last system time of animation run
#**************************************************************************************

# Begins game loop, initializes time
GAME_START:
	
	li	$v0, 30		# System time service
	syscall			# a0 = lower 32 bits of sys time
	move	$s3, $a0	# Store start time in s3
	move	$t9, $a0
	
# void TIME_LOOP
# gets current system time, compares to last system time of successful animation  
#
# arguments: a0 = current system time, t9 = system time to check against
# trashes: t1
TIME_LOOP: 
	li	$v0, 30			# System time service
	syscall				# a0 = lower 32 bits of sys time
	sub	$t1, $a0, $t9		# Check time difference 
	blt	$t1, 200, TIME_LOOP	# if <200ms passed, reloop
	move	$t9, $a0		# Else, update last run time
	
#**************************************************************************************

CHECK_DIR:
	lbu	$s6, 0xFFFF0004
	beq	$s6, 0x42, GAME_OVER	# quit the game if b is pressed
	
	lb	$a1, ($s4) 		# Get head y coordinate	
	lb	$a0, 1($s4)		# Get head x coordinate
	
	beq	$s6, 0xE0, _UP		# go up if w is pressed
	beq	$s6, 0xE2, _LE		# go left if a is pressed
	beq	$s6, 0xE1, _DO		# go down if s is pressed
	beq	$s6, 0xE3, _RI		# go right if d is pressed
	
	_UP:	addi	$a1, $a1, -1	# Decrement y
		beq	$a1, -1, UP_63
		j 	CHECK_NEXT
		
	_LE:	addi	$a0, $a0, -1	# Decrement x
		beq	$a0, -1, LE_63
		j 	CHECK_NEXT
		
	_DO:	addi	$a1, $a1, 1	# Increment y
		beq	$a1, 64, DO_0
		j 	CHECK_NEXT
		
	_RI:	addi	$a0, $a0, 1	# Increment x
		beq	$a0, 64, RI_0
		j 	CHECK_NEXT
		
#**************************************************************************************

UP_63:	
	li	$a1, 63
	j	CHECK_NEXT

LE_63:
	li	$a0, 63
	j	CHECK_NEXT
	
DO_0: 	li	$a1, 0
	j	CHECK_NEXT
	
RI_0:	li	$a0, 0
	j	CHECK_NEXT

#**************************************************************************************

CHECK_NEXT: 
	# load x and y from head pointer to a0 and a1
	# increment coordinates appropriately based on current direction
	jal	_getLED
	beq	$v0, 0, MOVE		# if next space is empty, move
	beq	$v0, 1, CHANGE_DIR	# if next space is a wall, change direction
	beq	$v0, 2, LOSE		# if next space is the snake, game is LOST
	j	GROW			# Else, only remaining option is a frog, so
					# to GROW
#**************************************************************************************

# Moves snake forward in current direction
#
# Arguments: 
# Trashes: 
#
MOVE:	
	li	$a2, 2		# Set next LED to snake
	jal	_setLED		# Turn on next LED
	
	la	$t7, _snake		# Get address of queue
	addi	$t7, $t7, 79		# Add max offset
	sub	$t7, $t7, $s4		
	move	$a3, $s4
	bltzal	$t7, RESET_QUEUE	# Reached end of snake mem, wrap around
	move	$s4, $a3
	
	addi	$s4, $s4, 2	# Increment head pointer
	sb	$a1, ($s4)	# Store new y coordinate
	sb	$a0, 1($s4)	# Store new x coordinate

	lb	$a1, ($s5)	# Get tail y coordinate
	lb	$a0, 1($s5)	# Get tail x coordinate
	li	$a2, 0		# Turn tail off
	jal	_setLED		
	
	la	$t7, _snake		# Get address of queue
	addi	$t7, $t7, 79		# Add max offset
	sub	$t7, $t7, $s5		
	move	$a3, $s5
	bltzal	$t7, RESET_QUEUE	# Reached end of snake mem, wrap around
	move	$s5, $a3	
	
	addi	$s5, $s5, 2	# increment tail pointer
	move	$s7, $s6	# Set previous direction
	li	$t8, 0		# Reset change_dir check
	j TIME_LOOP		# Begin next animation sequence
	
#**************************************************************************************

# Moves head forward (but not tail) and increments score
#
# Arguments:
# Trahes:
#
GROW: 
	li	$a2, 2		# Set next LED to snake
	jal	_setLED		# Turn on next LED
	
	la	$t7, _snake		# Get address of queue
	addi	$t7, $t7, 79			# Add max offset
	sub	$t7, $t7, $s4		
	move	$a3, $s4
	bltzal	$t7, RESET_QUEUE	# Reached end of snake mem, wrap around
	move	$s4, $a3
	
	addi	$s4, $s4, 2	# Increment head pointer
	sb	$a1, ($s4)	# Store new y coordinate
	sb	$a0, 1($s4)	# Store new x coordinate
	addi	$s2, $s2, 1	# Increment score
	move	$s7, $s6	# Set previous direction
	li	$t8, 0		# Reset change_dir check
	j 	TIME_LOOP	# Start next animation

#**************************************************************************************

RESET_QUEUE:
	la	$a3, _snake
	addi	$a3, $a3, 1
	jr	$ra

#**************************************************************************************

# Changes current direction to avoid collision with a wall
# Checks which direction is viable and won't lead to LOSE
# If a viable dir is found, set current dir to that and do CHECK_DIR again
#  set a temp var to check if direction has already been changed -> LOSE
# Else, it will just MOVE after checking again
#
# Arguments: 
# Trashes: 
#
CHANGE_DIR:
	beq	$t8, 3, LOSE		# Stuck in a corner, LOSE
	blt	$s6, 0xE2, GO_LE	# If moving up/down, change direction to left
	
	beq	$t8, 2, GO_DO
	li	$s6, 0xE0		# If moving left/right, change dir to up
	sb	$s6,0xFFFF0004		# Store new dir
	addi	$t8, $t8, 1		# Increment change_dir check
	j	CHECK_DIR
	
GO_DO:	li	$s6, 0xE1		# If moving left/right, change dir to up
	sb	$s6,0xFFFF0004		# Store new dir
	addi	$t8, $t8, 1		# Increment change_dir check
	j	CHECK_DIR

GO_LE:	beq	$t8, 2, GO_RI		# If already tried left, go right
	
	li	$s6, 0xE2		# If moving up/down, change dir to left
	sb	$s6,0xFFFF0004		# Store new dir
	addi	$t8, $t8, 1		# Increment change_dir check
	j	CHECK_DIR
	
GO_RI:	li	$s6, 0xE3		# If moving up/down, change dir to left
	sb	$s6,0xFFFF0004		# Store new dir
	addi	$t8, $t8, 1		# Increment change_dir check
	j	CHECK_DIR

#**************************************************************************************
#				Game loop over
#**************************************************************************************

# Game is over, either due to winning or meeting a lose condition
# Displays game over message
#  -Score
#  -Time played
WIN:	li	$v0, 4			# Print string service
	la	$a0, win_message	# Load win_message
	syscall				# Print
	j	GAME_OVER

LOSE:	li	$v0, 4			# Print string service
	la	$a0, lose_message	# Load lose_message
	syscall				# Print 
	j	GAME_OVER

GAME_OVER:
	li	$v0, 4
	la	$a0, score_message	# Load score_message
	syscall				# Print string
	
	li	$v0, 1			# Print int service
	move	$a0, $s2		# Load score into a0
	syscall				# Print score
	
	li	$v0, 4			# Print string service
	la	$a0, time_message	# Load time_message
	syscall				# Print string
	
	li	$v0, 1			# Print int service
	sub	$a0, $t9, $s3		# Get time played
	syscall				# Print time
	
	li	$v0, 4			# Print string service
	la	$a0, unit_message	# Load unit_message
	syscall				# Print string
	
	li	$v0, 10			# Terminate program
	syscall		
	
#**************************************************************************************
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

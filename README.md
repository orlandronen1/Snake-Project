# Snake-Project
Midterm project
Ronen Orland and Julian Linkhauer

Process:
1. Build walls
  - Read the wall string(s)
  - At every "I", set the LED on as red (wall)
  - Stop at null character
2. Build snake
  - Sets on tail LED and initializes the tail pointer
  - Sets on body LEDs
  - Sets on head LED and initializes the head pointer
3. Populate frogs
  - Does 32 attempts of putting a frog on the board
  - Generates random coordinates, then checks the LED at that spot
  - If anything is already there, skip generating that frog
  - Keeps a counter of how many frogs were generated, used to check against the score during the game
4. Initialize timer/game
  - Store game start time
5. Game Loop
  - Timer loop
    - Compare current system time to last time of animation/loop completion
    - If less than 200ms, continue looping until 200ms have passed
  - Check Direction
    - Checks the direction to go in by loading the byte where key presses are stored (defaulted to right in start of game)
    - Once direction is determined, get coordinates of head and increment appropriately
    - If designated spot is empty, jump to Move
    - If designated spot is a wall, jump to Change Direction
    - If designated spot is the snake, jump to lose message in Game Over
    - Else, the spot is a frog, jump to Grow
    - Change Direction
  - Move
    - Increment head pointer and set the new LED on
    - Set tail LED off and increment tail pointer
  - Grow
    - Increment head pointer and set the new LED on
    - Increment the score
    - If the score is equal to the number of generated frogs, go to the win message in Game Over
6. Game Over
  - Display win/lose message
  - Display time and score
    - Calculates play time from difference b/w game start time and time of Game Over

Notes: 
- Changed A to be left and S to be down
- Key presses on the keyboard won't work until one press on the on-screen keys on the simulator
- Trying to move in the opposite direction of current movement (i.e. moving left when already moving right) will trigger loss
- Liable to crash if keys are pressed too quickly

# Snake-Project
Midterm project
Ronen Orland and Julian Linkhauer

Process:
1. Build walls
  - Read the wall string(s)
  - At every "I", set the LED on as red (wall)
  - Stop at null character
2. Build snake
3. Populate frogs
4. Initialize timer/game
5. Game Loop
  - Timer loop
  - Check Direction
    - Change direction
  - Move
  - Grow
6. Game over
  - Display win/lose message
  - Display time and score

Notes: 
- Changed A to be left and S to be down
- Key presses on the keyboard won't work until one press on the on-screen keys on the simulator

import java.util.Vector;
import processing.sound.*;

Player p1;
Vector<Food> meats = new Vector<Food>();
int score = 0;
boolean gameOver = false;
boolean instructionScreen = true;
boolean instructions = false;

PImage background, ground, gator, meatImg, bang, powerUp, powerDown;
PFont title, normal;
SoundFile bgMusic, nomSound;
Button startButton, quitButton, easyButton, notEasyButton, instButton;
boolean gameStarted = false;
boolean startGame = false;
boolean easyMode = false;

int lastPowerSpawnTime = 0;
int powerInterval = 10000;
boolean spawnPowerUp = true;


/*
Setup Function:
- Set up the size of the canvas
- Load images and sounds files 
- Create a new player object
- Sets difficulty level with buttons
*/

void setup() {
  size(400, 400);
  p1 = new Player(3);
  background = loadImage("background.png");
  ground = loadImage("grassGround.png");
  gator = loadImage("gator.png");
  meatImg = loadImage("meat.png");
  bang = loadImage("bang.png");

  title = loadFont("Dubai-Bold-48.vlw");
  normal = loadFont("LucidaSans-28.vlw");
  powerUp = loadImage("arrow_up.png");
  powerDown = loadImage("arrow_down.png");
  
  bgMusic = new SoundFile(this, "game_score.mp3");
  nomSound = new SoundFile(this, "nom_nom_sound.mp3");
  bgMusic.loop();
  bgMusic.amp(.05);

  startButton = new Button(width/2, height/2 + 100, 100, 30, "Start", color(0, 0, 255));
  quitButton = new Button(width/2, height/2 + 150, 100, 30, "End", color(255, 0, 0));
  easyButton = new Button(width/2, height/2 + 70, 80, 30, "Easy", color(0, 0, 255));
  notEasyButton = new Button(width/2, height/2 + 120, 80, 30, "Not Easy", color(255, 0, 0));
  instButton = new Button(width/2, height/2 + 50, 100, 30, "Instructions", color(#AA90FF));
}

/*
Mouse Pressed Function:
- If the instructions are displayed, player can choose to "start" or "quit" the game. 
*/

void displayInst()
{
  fill(#0B5A01);
  text("- Use arrow keys to move the gator left and right", width / 2, height / 2 - 40);
  text("- Catch the falling meats to increase your score", width / 2, height / 2 - 15);
  text("- Avoid letting meats fall off the \nbottom of the screen", width / 2, height / 2 + 10);
}

void gameName()
{
  textFont(title);
  fill(#094302);
  text("CHOMP CHOMP", width/2, height/2 - 60);
  textFont(normal, 15);
}

void mousePressed() {
  if (instructionScreen) {
    if(instButton.clicked())
    {
      instructions = true;
    }
    if (startButton.clicked()) {
      println("Start button clicked");
      instructionScreen = false;
      gameStarted = true; 
    }
    if (quitButton.clicked()) {
      exit();
    }
  } else if (gameStarted) { 
    if (easyButton.clicked()) {
      println("Easy mode selected");
      startGame = true;
      easyMode = true;
      p1.speedMultiplier = 1;
      
    }
    if (notEasyButton.clicked()) {
      println("Not Easy mode selected");
      startGame = true;
      easyMode = false;
       p1.speedMultiplier = 2.0;
    }
  } else {
    if (gameOver) {
      exit();
    }
  }
}


/*
Display Instructions Function:
- Displays game play instructions on the screen
*/

void startMenu()
{
  background(#B8E6E2);
  image(ground, 0, 250, 400, 400);
}

void displayInstructions() {
  background(255);
  image(background, 0, 0, 400, 400);
  textAlign(CENTER);
  textSize(20);
  fill(255);
  text("Instructions:", width / 2, height / 2 - 75);
  

  println("boolean variable: " + gameStarted + " " + startGame + " " + easyMode);
  if (instructionScreen) {
    startMenu();
    gameName();
    if(instructions)
    {
      displayInst();
    }
    instButton.display();
    startButton.display();
    quitButton.display();
  }else if (gameStarted && !startGame) {
    println("In game started, instructions screen");
    text("Select a difficulty level:", width / 2, height / 2 - 40);
    easyButton.display();
    notEasyButton.display();
  }
}

/*
Draw Function:
- The draw function displays the game, player, and score on the screen 
- Tracks the number of lives the player has left, if the player has no lives left, the game ends
*/

void draw() {
  if (instructionScreen || (gameStarted && !startGame)) {
    displayInstructions();
  } else if (gameStarted && startGame) {
    background(255);
    image(background, 0, 0, 400, 400);
    p1.display();
    p1.movePlayer();
    p1.numLives();
    
    if (!gameOver) {
      for (int i = meats.size() - 1; i >= 0; i--) { // Update and display meats
        Food m = meats.get(i);
        m.update(); // Update position on food class
        m.display(); // Display position in food class
        if (m.checkCollision(p1)) {
          score++; // Increment score if gator catches meat
          meats.remove(i); // Remove meat if caught by gator
          nomSound.play();
        } else if (m.isOffscreen()) {
          meats.remove(i); // Remove meat if it goes offscreen
          p1.decrementLives(); // Decrement lives if meat falls offscreen
          if (p1.getNumLives() == 0) {
            gameOver = true; // End game if numLives reaches zero
            bgMusic.stop(); // Stop backgroyund music
          }
        }
      }
      
       if (millis() - lastPowerSpawnTime > powerInterval) {
        if (spawnPowerUp) {
          meats.add(new PowerUp());
        } else {
          meats.add(new PowerDown());
        }
        lastPowerSpawnTime = millis();
        spawnPowerUp = !spawnPowerUp; // Toggle between powerUp and powerDown
      }
      
      if (frameCount % 50 == 0) { // Generate new meats at top of screen every 60 frames
        meats.add(new Food());
      }
    } else { // Game Ends
      fill(255, 0, 0);
      textSize(40);
      textAlign(CENTER);
      text("Game Over", width/2, height/2);
    }
  }
}

/*
Button Class:
- The button class contains the x and y position, width, height, label, and color of the button.
- Display Function: Displays the button on the screen
- Clicked Function: Checks if the button has been clicked
*/

class Button {
  float x, y, w, h;
  String label;
  color c;

  Button(float x, float y, float w, float h, String label, color c) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.c = c;
  }

  void display() {
    rectMode(CENTER);
    fill(c);
    rect(x, y, w, h);
    textAlign(CENTER, CENTER);
    fill(255);
    text(label, x, y);
  }

  boolean clicked() {
    return mouseX > x - w/2 && mouseX < x + w/2 && mouseY > y - h/2 && mouseY < y + h/2;
  }
}


/*
Player Class:
- The player class contains the player's number of lives and x position
- Move Player Function: Moves the player left and right using the arrow keys
- Num Lives Function: Displays the player's score and number of lives on the screen
- Get Num Lives Function: Returns the number of lives the player has left
- Decrement Lives Function: Decrements the number of lives the player has left
- Display Function: Displays the player on the screen
*/

class Player {
  int numLives;
  int xPos;
  boolean powerUpActive = false;
  int powerUpTimer = 0;
  boolean powerDownActive = false;
  int powerDownTimer = 0;
  float speedMultiplier = 1; 

  Player(int numLives) {
    this.numLives = numLives;
    xPos = 0;
  }

  void movePlayer() {
if (powerUpActive) {
      // Double the speed
      if (keyPressed) {
        if (key == CODED) {
          if (keyCode == RIGHT) {
            xPos += 10; // Double the speed for right movement
            xPos = constrain(xPos, 0, width - 100);
          } else if (keyCode == LEFT) {
            xPos -= 10; // Double the speed for left movement
            xPos = constrain(xPos, 0, width - 100);
          }
        }
      }
      // Decrease the powerUp timer
      powerUpTimer--;
      // If powerUp timer reaches zero, deactivate powerUp
      if (powerUpTimer <= 0) {
        powerUpActive = false;
      }
    } 
    else if(powerDownActive) {
      if (keyPressed) {
        if (key == CODED) {
          if (keyCode == RIGHT) {
            xPos += 1.5; // Double the speed for right movement
            xPos = constrain(xPos, 0, width - 100);
          } else if (keyCode == LEFT) {
            xPos -= 1.5; // Double the speed for left movement
            xPos = constrain(xPos, 0, width - 100);
          }
        }
      }
      // Decrease the powerUp timer
      powerDownTimer--;
      // If powerUp timer reaches zero, deactivate powerUp
      if (powerDownTimer <= 0) {
        powerDownActive = false;
      }
    }
    else {
      // Normal speed
      if (keyPressed) {
        if (key == CODED) {
          if (keyCode == RIGHT) {
            xPos += 6;
            xPos = constrain(xPos, 0, width - 100);
          } else if (keyCode == LEFT) {
            xPos -= 6;
            xPos = constrain(xPos, 0, width - 100);
          }
        }
      }
    }
  }

  void numLives() {
    if (!instructionScreen) {
      fill(255);
      textSize(20);
      text("Score: " + score, 45, 20);  
      text("Number of lives: " + numLives, 90, 55);  
    }
  }


  int getNumLives() {
    return numLives;
  }

  void decrementLives() {
    numLives--;
  }

  void display() {
    image(gator, xPos, height - 100, 100, 100);
  }
}

/*
Food Class:
- The food class contains the x and y position of the meat
- Display Function: Displays the meat on the screen
- Update Function: Updates the position of the meat
- Check Collision Function: Checks if the meat has collided with the player
- Is Offscreen Function: Checks if the meat has gone offscreen
*/

class Food {
  float x;
  float y;
  float speed = 2;

  Food() {
    x = random(width - 50);
    y = -50;
  }

  void display() {
    if (y > height) {
      // Meat has hit the ground, display the "bang.png" image
      image(bang, x, height - 50, 100, 50);
    }else {
      image(meatImg, x, y, 100, 100); // Display meatImg otherwise
    }
  }

  void update() {
    y += speed * p1.speedMultiplier;
  }

boolean checkCollision(Player p) {
  if (x > p.xPos && x < p.xPos + 100 && y + 50 > height - 100) {
    if (this instanceof PowerUp) {
      // Activate powerUp effect
      p.powerUpActive = true;
      p.powerUpTimer = 300; // 5 seconds (300 frames at 60 fps)
      return true; // Collision detected, but no score increase for powerUp
    } else if (this instanceof PowerDown) {
      // Activate powerDown effect
      p.powerDownActive = true;
      p.powerDownTimer = 300; // 5 seconds (300 frames at 60 fps)
      return true; // Collision detected, but no score or lives change for powerDown
    } else {
      return true; // Collision detected, increase score for other foods
    }
  }
  return false; // No collision
}

  boolean isOffscreen() {
    if (y > height) {
      return true;
    }
    return false; // Return true if meat is offscreen
  }
}

class PowerUp extends Food {
  PowerUp() {
    super(); // Call the constructor of the superclass (Food)
    x = random(width - 50); // Randomize x position
    y = -50; // Start from the top of the screen
    speed = 1.5; // Set the speed
  }
  void display() {
    image(powerUp, x, y, 50, 50); // Display the powerUp image
  }
}

class PowerDown extends Food {
  PowerDown() {
    super(); // Call the constructor of the superclass (Food)
    x = random(width - 50); // Randomize x position
    y = -50; // Start from the top of the screen
    speed = 2; // Set the speed
  }
  void display() {
    image(powerDown, x, y, 50, 50); // Display the powerDown image
  }
}

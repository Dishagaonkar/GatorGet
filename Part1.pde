import java.util.Vector;
import processing.sound.*;

Player p1;
Vector<Food> meats = new Vector<Food>();
int score = 0;
boolean gameOver = false;
boolean instructionScreen = true;

PImage background, gator, meatImg, bang;
SoundFile bgMusic, nomSound;


/*
Setup Function:
- Set up the size of the canvas
- Load images and sounds files 
- Create a new player object
*/

void setup() {
  size(400, 400);
  p1 = new Player(3);
  background = loadImage("background.png");
  gator = loadImage("gator.png");
  meatImg = loadImage("meat.png");
  bang = loadImage("bang.png");
  
  bgMusic = new SoundFile(this, "game_score.mp3");
  nomSound = new SoundFile(this, "nom_nom_sound.mp3");
  bgMusic.loop();
  bgMusic.amp(.05);
}

/*
Key Pressed Function:
- If the instruction screen is displayed, pressing any key will start the game
*/

void keyPressed() {
  if (instructionScreen) {
    instructionScreen = false;
  }
}

/*
Display Instructions Function:
- Displays game play instructions on the screen
*/

void displayInstructions() {
  background(255);
  image(background, 0, 0, 400, 400);
  textAlign(CENTER);
  textSize(20);
  fill(255);
  text("Instructions:", width / 2, height / 2 - 50);
  text("- Use arrow keys to move the gator left and right", width / 2, height / 2);
  text("- Catch the falling meats to increase your score", width / 2, height / 2 + 30);
  text("- Avoid letting meats fall off the \nbottom of the screen", width / 2, height / 2 + 60);
  text("- Press any key to begin", width / 2, height / 2 + 110);
}

/*
Draw Function:
- The draw function displays the game, player, and score on the screen 
- Tracks the number of lives the player has left, if the player has no lives left, the game ends
*/

void draw() {
  if (instructionScreen) {
    displayInstructions();
  } else {
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
      
      if (frameCount % 50 == 0) { // Generate new meats at top of screen every 60 frames
        meats.add(new Food());
      }
    } 
    else { // Game Ends
      fill(255, 0, 0);
      textSize(40);
      textAlign(CENTER);
      text("Game Over", width/2, height/2);
    }
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

  Player(int numLives) {
    this.numLives = numLives;
    xPos = 0;
  }

  void movePlayer() {
    if (keyPressed) {
      if (key == CODED) {
        if (keyCode == RIGHT) {
          xPos += 3;
          xPos = constrain(xPos, 0, width - 100);
        } else if (keyCode == LEFT) {
          xPos -= 3;
          xPos = constrain(xPos, 0, width - 100);
        }
      }
    }
  }

  void numLives() {
    if (!instructionScreen) {
      fill(255);
      textSize(20);
      text("Score: " + score, 40, 20);  
      text("Number of lives: " + numLives, 80, 50);  
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
    y += speed;
  }

  boolean checkCollision(Player p) {
    if (x > p.xPos && x < p.xPos + 100 && y + 50 > height - 100) {
      return true; // Collision detected
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

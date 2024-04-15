import java.util.Vector;
import processing.sound.*;

Player p1;
Vector<Food> meats = new Vector<Food>();
int score = 0;
boolean gameOver = false;
boolean instructionScreen = true;

PImage background, gator, meatImg, bang, powerUp, powerDown;
SoundFile bgMusic, nomSound;

int lastPowerSpawnTime = 0;
int powerInterval = 10000;
boolean spawnPowerUp = true;

void setup() {
  size(400, 400);
  p1 = new Player(6);
  background = loadImage("background.png");
  gator = loadImage("gator.png");
  meatImg = loadImage("meat.png");
  bang = loadImage("bang.png");
  powerUp = loadImage("arrow_up.png");
  powerDown = loadImage("arrow_down.png");
  
  bgMusic = new SoundFile(this, "game_score.mp3");
  nomSound = new SoundFile(this, "nom_nom_sound.mp3");
  bgMusic.loop();
  bgMusic.amp(.05);
}

void keyPressed() {
  if (instructionScreen) {
    instructionScreen = false;
  }
}


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
    } 
    else { // Game Ends
      fill(255, 0, 0);
      textSize(40);
      textAlign(CENTER);
      text("Game Over", width/2, height/2);
    }
  }
}


class Player {
  int numLives;
  int xPos;
  boolean powerUpActive = false;
  int powerUpTimer = 0;
  boolean powerDownActive = false;
  int powerDownTimer = 0;

  Player(int numLives) {
    this.numLives = numLives;
    xPos = 0;
  }

  void movePlayer() {
    // Check if powerUp is active
    if (powerUpActive) {
      // Double the speed
      if (keyPressed) {
        if (key == CODED) {
          if (keyCode == RIGHT) {
            xPos += 6; // Double the speed for right movement
            xPos = constrain(xPos, 0, width - 100);
          } else if (keyCode == LEFT) {
            xPos -= 6; // Double the speed for left movement
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
            xPos += 3;
            xPos = constrain(xPos, 0, width - 100);
          } else if (keyCode == LEFT) {
            xPos -= 3;
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

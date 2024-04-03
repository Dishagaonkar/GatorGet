import java.util.Vector;

Player p1;
Vector<Food> meats = new Vector<Food>();
int score = 0;
boolean gameOver = false;

PImage background, gator, meatImg;

void setup() {
  size(400, 400);
  p1 = new Player(3);
  background = loadImage("background.png");
  gator = loadImage("gator.png");
  meatImg = loadImage("meat.png");
}

void draw() {
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
      } else if (m.isOffscreen()) {
        meats.remove(i); // Remove meat if it goes offscreen
        p1.decrementLives(); // Decrement lives if meat falls offscreen
        if (p1.getNumLives() == 0) {
          gameOver = true; // End game if numLives reaches zero
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
    fill(255);
    textSize(20);
    text("Score: " + score, 20, 20);
    text("Number of lives: " + numLives, 20, 50);
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
    image(meatImg, x, y, 50, 50);
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
    return y > height; // Return true if meat is offscreen
  }
}

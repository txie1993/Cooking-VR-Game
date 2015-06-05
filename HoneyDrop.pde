class HoneyDrop
{
  float x, y, x1, y1;

  //float angle = 0;
  float speed;

  int type;

  HoneyDrop(float x, float y)
  {
    this.x = x;
    this.y = y;


    speed = random(1, 3);
    //angle = random(0,360);
  }

  void display()
  {
    imageMode(CENTER);
    //pushMatrix();
    //translate(x, y);
    //rotate(radians(angle));
    
      image(honey_drop, x, y, 50, 75);
    
    //    else
    //    {
    //      image(lollypop, 0, 0);
    //    }
    //popMatrix();

    //angle += 1;
  }

  void move()
  {
    this.y += speed;

    if (this.y > height+50)
    {
      reset();
    }
  }

  void reset()
  {
    this.y = -100;
    this.x = random(50, width-50);
  }
  
  void checkHit(float x1, float y1)
  {
  if (dist(x, y, x1, y1) < 50)
    {
      honeyPoints++;
      reset();
    }
  }
  
}


class Warrior
{
  public void setHealth(int val)
  { 
    health = val; 
  }
  public int getHealth() 
  {
    return health; 
  }
  private int health;
}

public class AttrAccessor
{
    public static void main(String[] args) 
    {
      Warrior s = new Warrior();
      s.setHealth(95);
      System.out.println("Health = " + s.getHealth());
    }
}


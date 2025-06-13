# Bugs
- Units not updating preview tiles or any information in general unless they are selected. This should happen after every action
- Targets in an attackable tile but not walkable skip moving and attack completely outside of attack range
- Preview Arrow is drawn even when player cannot move there. This will also fix incorrect attack range pathing
  - Fix: Implement method to find walkable tiles that are in range of the enemy, then find which one has the shortest A* path
  - Modify existing flood fill searches to use a dictionary based on number of moves. Then use this dictionary to determine shortest path without needing to run A*
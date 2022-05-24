# ProcedurallyGeneratedTerrainMaps

### Description

A brief experiment in generating procedurally generated terrain maps.

Main idea is generating a height map from Perlin noise, colouring  the pixel or quad in question based on a height look-up, then finally display.
Also added a marching squares algorithm.

Repo contains 2 sub-projects:
- **TerrainGenerator2D** - Standard 2D perlin noise used to generate heightmap, which is then modified to create an island by pushing down image edges and pulling up the center. N.B. Opens in fullscreen because why not.
  - Hint: Press 'c' to toggle the marching squares algorithm.
- **TerrainGenerator3D** - Experiment in porting TerrainGenerator2D into 3D, using P3D in Processing. Main aim/challenge was to create the mesh generation code. Takes a while to generate mesh but runs fairly smoothly.

### Inspiration

This mini project was heavily inspired from Amit Patel's work on RedBlobGames, namely:
- http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/
- https://www.redblobgames.com/maps/terrain-from-noise/

### Misc.

The original aim was to build up from a Voronoi cell base, similar to Amit's [Polygonal Map Generator](https://www.redblobgames.com/maps/mapgen2/) and Oskar Stälberg's [Townscaper](https://oskarstalberg.com/Townscaper/). Processing was a quick and dirty way to prototype parts of it, but a bit too limiting to go further than this current project, at some point I'd like to try this again in Unity or the like.

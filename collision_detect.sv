// This module detects any potential collision that may happen between 
// pacman and ghost/wall/dot/pill and return the collision type
// for collsion between dot & pill that happened, module will remove
// dot or pill from the look up map
module collision_detect
			(CLOCK_50, reset, next_pacman_x, next_pacman_y, 
			 next_ghost1_x, next_ghost1_y, next_ghost2_x, next_ghost2_y,
			 collision_type);
	input logic CLOCK_50, reset;
	input logic [5:0] next_pacman_x, next_ghost1_x, next_ghost2_x;
	input logic [4:0] next_pacman_y, next_ghost1_y, next_ghost2_y;

	

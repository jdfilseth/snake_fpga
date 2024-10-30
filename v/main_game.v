module main_game (
	input hard_reset,
	input game_reset,
	input clk,
	input [5:0] rand_x,
	input [4:0] rand_y,
	input [2:0] input_direction,
	output is_start_screen,
	output is_over,
	output [BOARD_WIDTH*BOARD_HEIGHT*3-1:0] board_state,
	output [10:0] score
);
`include "game_vga_param.h"

reg is_start_screen_reg;
assign is_start_screen = is_start_screen_reg;

reg is_over_reg;
assign is_over = is_over_reg;

reg [2:0] board_state_reg [BOARD_WIDTH-1:0] [BOARD_HEIGHT-1:0];

// assign board_state output to board_state_reg
genvar v;
generate
	for (v=0; v<BOARD_WIDTH*BOARD_HEIGHT; v=v+1) begin : regboardgen
		assign board_state[v*3+2:v*3] = board_state_reg[v/BOARD_HEIGHT][v%BOARD_HEIGHT];
	end
endgenerate

reg generate_dot;

reg[10:0] score_reg;
assign score = score_reg;

reg[10:0] max_size;
reg[10:0] current_size;
reg[30:0] current_speed;

reg[30:0] cnt;

reg[5:0] head_h, tail_h;
reg[4:0] head_v, tail_v;

wire[1:0] direction;

// only assign a new direction if it's orthogonal to current motion of snake
assign direction = ((board_state_reg[head_h][head_v][0] == 1) &&
	(input_direction!=1 && input_direction!=3)) ||
	((board_state_reg[head_h][head_v][0] == 0) &&
	(input_direction!=0 && input_direction!=2)) ?
	board_state_reg[head_h][head_v] - 1 : input_direction[1:0];


wire[5:0] h_mod;
wire[4:0] v_mod;
assign v_mod = (direction==2) - (direction==0);
assign h_mod = (direction==3) - (direction==1);


// main logic of program
integer i, j;
always @ (posedge clk)
begin

	// reset game if reset is pushed
	if (!game_reset || !hard_reset)
	begin
		if (!hard_reset)
			is_start_screen_reg <= 1;
		else if (!game_reset)
			is_start_screen_reg <= 0;
		
		generate_dot <= 1;
		current_speed <= START_SPEED;
		cnt <= 0;
		is_over_reg <= 0;
		score_reg <= 0;
		max_size <= 3;
		current_size <= 3;
		head_h <= 20;
		head_v <= 20;
		tail_h <= 20;
		tail_v <= 22;
		for (i=0;i<BOARD_WIDTH;i=i+1)
		begin
			for (j=0;j<BOARD_HEIGHT;j=j+1)
			begin
				if (i==20 && j>=20 && j<=22)
					board_state_reg[i][j] <= 1; // 1-4 means snake is located there
				else
					board_state_reg[i][j] <= 0; // empty space
			end
		end
	end

	else if (hard_reset && game_reset && !is_start_screen_reg && !is_over_reg)
	begin
		if (cnt==current_speed)
		begin
			cnt <= 0;
			// end game if snake crashes into wall
			if (
				(direction==0 && head_v==0) ||
				(direction==1 && head_h==0) ||
				(direction==2 && head_v==BOARD_HEIGHT-1) ||
				(direction==3 && head_h==BOARD_WIDTH-1)
			)
			begin
				is_over_reg <= 1;
			end
			else
			begin
				// update head coordinates
				head_h <= head_h + h_mod;
				head_v <= head_v + v_mod;
			
				// update old head to track location of newly added segment
				board_state_reg[head_h][head_v] <= direction + 1;

				// end game if snake crashes into itself unless 2 things are true:
				// 1) it's the tail segment (i.e. snake forms a perfect loop)
				// 2) the tail segment gets removed at the same time
				if (
					board_state_reg[head_h+h_mod][head_v+v_mod] > 0 && board_state_reg[head_h+h_mod][head_v+v_mod] < 7
					&& !(
						head_h+h_mod==tail_h && head_v+v_mod==tail_v && 
						board_state_reg[head_h+h_mod][head_v+v_mod] != 7 &&
						current_size >= max_size
					)
				)
				begin
					is_over_reg <= 1;
				end
				else
				begin
					// add new head to snake (set the value of the current direction to prevent backwards direction settings)
					board_state_reg[head_h+h_mod][head_v+v_mod] <= direction + 1;
					
					// if didn't eat a dot, remove current tail from snake and update tail coordinates
					if (board_state_reg[head_h+h_mod][head_v+v_mod] != 7 && current_size>=max_size)
					begin
						// erase tail segment unless it is replaced by new head
						if (!(head_h+h_mod==tail_h && head_v+v_mod==tail_v))
							board_state_reg[tail_h][tail_v] <= 0;
						
						// update tail coordinates
						if (board_state_reg[tail_h][tail_v]==1)
							tail_v <= tail_v - 1;
						else if (board_state_reg[tail_h][tail_v]==2)
							tail_h <= tail_h - 1;
						else if (board_state_reg[tail_h][tail_v]==3)
							tail_v <= tail_v + 1;
						else if (board_state_reg[tail_h][tail_v]==4)
							tail_h <= tail_h + 1;
					end
					else 
					begin
						if (board_state_reg[head_h+h_mod][head_v+v_mod] == 7)
						begin
							// generate new dot
							generate_dot <= 1;
							
							// increment score by 1
							score_reg <= score_reg + 1;
							
							// increase max size of snake
							max_size <= max_size + GROWTH_RATE;

							// increase speed of snake
							current_speed <= current_speed - (current_speed*3/256);
						end
						
						// increase current size of snake
						current_size <= current_size + 1;
					end
					
				end
				
			end
			
		end
		else
		begin
			cnt <= cnt + 1;
		end
		
		// attempt to generate new dot if it is needed, but only put it in empty square
		if (generate_dot && board_state_reg[rand_x][rand_y]==0 && !(rand_x==head_h+h_mod && rand_y==head_v+v_mod))
		begin
			board_state_reg[rand_x][rand_y] <= 7;
			generate_dot <= 0;
		end
	end
	
	
end


endmodule
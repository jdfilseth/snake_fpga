// generates pseudorandom integers between 0 and BOARD_WIDTH (rand_x); 0 and BOARD_HEIGHT (rand_y)
module rng (
	input clk,
	input reset,
	output wire [BOARD_WIDTH_BITS-1:0] rand_x,
	output wire [BOARD_HEIGHT_BITS-1:0] rand_y 
);

`include "game_vga_param.h"

reg[15:0] main_reg;
assign rand_x = main_reg[15:8] % BOARD_WIDTH;
assign rand_y = main_reg[7:0] % BOARD_HEIGHT;

// LFSR feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1 
wire feedback;
assign feedback = main_reg[15] ^ main_reg[13] ^ main_reg[12] ^ main_reg[10];

always @ (posedge clk)
begin
	if (!reset)
		main_reg <= main_reg/2 + 1; // hitting reset ensures LFSR not in zero state
	else
		main_reg <= {main_reg[14:0], feedback};
end


endmodule
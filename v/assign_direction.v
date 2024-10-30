// converts X and Y input into a direction
module assign_direction(
	input wire [9:0] input_x,
	input wire [9:0] input_y,
	output wire [2:0] direction
);

wire [8:0] abs_x, abs_y;

// absolute value of x and y inputs
assign abs_x = input_x[9] ? ~input_x : input_x;
assign abs_y = input_y[9] ? ~input_y : input_y;

// direction[0] is 1 if "left"/"right", 0 if "up"/"down"
assign direction[0] = (abs_y > abs_x);

// direction[1] is 1 for "down"/"right" and 0 for "up"/"left"
assign direction[1] = ((abs_x >= abs_y) && !input_x[9]) || ((abs_y > abs_x) && input_y[9]);

// direction[2] is 1 if the controller is nearly flat (i.e. no clear direction)
assign direction[2] = (abs_y<50 && abs_x<50); // direction >=4 means no clear direction

endmodule
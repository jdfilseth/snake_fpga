module score_counter (
	input [10:0] score,
	output [7:0] hex0,
	output [7:0] hex1,
	output [7:0] hex2,
	output [7:0] hex3,
	output [7:0] hex4,
	output [7:0] hex5
);

wire[20:0] score_out[5:0];
wire[7:0] hexes_inner[5:0];

genvar i;
generate
	for (i=0; i<6; i=i+1) begin : hex_gen_identifier
		assign score_out[i] = (score / (10**i)) % 10;
		display_hex d0 (.num(score_out[i]), .hex(hexes_inner[i]));
	end
endgenerate

assign hex0=hexes_inner[0];
assign hex1=hexes_inner[1];
assign hex2=hexes_inner[2];
assign hex3=hexes_inner[3];
assign hex4=hexes_inner[4];
assign hex5=hexes_inner[5];

endmodule


module display_hex (
	input [20:0] num,
	output [7:0] hex
);

assign hex[0] = (num==1) || (num==4);
assign hex[1] = (num==5) || (num==6);
assign hex[2] = (num==2);
assign hex[3] = (num==1) || (num==4) || (num==7) || (num==9);
assign hex[4] = (num==1) || (num==3) || (num==4) || (num==5) || (num==7) || (num==9);
assign hex[5] = (num==1) || (num==2) || (num==3) || (num==7);
assign hex[6] = (num==0) || (num==1) || (num==7);
assign hex[7] = 1;

endmodule
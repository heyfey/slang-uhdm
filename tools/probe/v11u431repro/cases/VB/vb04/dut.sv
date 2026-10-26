// § unitParamNameBindsDesign431 (a net declaration assignment)
localparam CF = 2;
module top(input [3:0] c, output y);
localparam CF = 1;
wire w = c[CF];
assign y = w;
endmodule

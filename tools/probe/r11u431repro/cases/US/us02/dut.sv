// § unitParamNameBindsDesign431 (residue: the $unit-parameter fold of TypeEmit's size-form dimension, sister ground)
localparam N = 4;
module sub(input clk, output [N-1:0] y);
assign y = '0;
endmodule
module top(input clk, output [3:0] y);
sub u(.clk(clk), .y(y));
endmodule

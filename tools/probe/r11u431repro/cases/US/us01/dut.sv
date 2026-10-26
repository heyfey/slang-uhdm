// § unitParamNameBindsDesign431 (residue: the $unit-parameter fold of TypeEmit's size-form dimension, sister ground)
localparam N = 4;
module sub(input clk);
reg [3:0] m [N];
endmodule
module top(input clk);
sub u(.clk(clk));
endmodule

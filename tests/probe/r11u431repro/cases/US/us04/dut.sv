// § unitParamNameBindsDesign431 (residue: the $unit-parameter fold of TypeEmit's size-form dimension, sister ground)
localparam N = 4;
module top(input [7:0] x, output y);
assign y = x[N];
endmodule

// § unitParamNameBindsDesign431 (an elaborated index in an always_comb, not a continuous assignment)
localparam CF = 0;
module sub(input [4:0] x, output logic z);
localparam CF = 2;
always_comb z = x[CF];
endmodule
module top(input [4:0] x, output z);
sub u(.x(x), .z(z));
endmodule

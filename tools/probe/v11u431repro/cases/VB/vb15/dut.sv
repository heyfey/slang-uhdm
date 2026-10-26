// § unitParamNameBindsDesign431 (elaborated index of a parameter NOT shadowing anything: control)
localparam CF = 0;
module sub(input [4:0] x, output z);
localparam XF = 1;
assign z = ~x[XF] ^ x[CF];
endmodule
module top(input [4:0] x, output z);
sub u(.x(x), .z(z));
endmodule

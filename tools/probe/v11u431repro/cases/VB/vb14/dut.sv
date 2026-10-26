// § unitParamNameBindsDesign431 (elaborated index under an operation x[CF+1])
localparam CF = 0;
module sub(input [4:0] x, output z);
localparam CF = 1;
assign z = ~x[CF+1];
endmodule
module top(input [4:0] x, output z);
sub u(.x(x), .z(z));
endmodule

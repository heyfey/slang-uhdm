// § unitParamNameBindsDesign431 (elaborated bit-select index of an OVERRIDDEN parameter)
localparam CF = 0;
module sub #(parameter CF = 1) (input [4:0] x, output z);
assign z = ~x[CF];
endmodule
module top(input [4:0] x, output z0, output z1);
sub #(.CF(3)) u0(.x(x), .z(z0));
sub u1(.x(x), .z(z1));
endmodule

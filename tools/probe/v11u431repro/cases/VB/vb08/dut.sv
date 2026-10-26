// § unitParamNameBindsDesign431 (an overridden parameter port in a child)
localparam CF = 2;
module sub #(parameter CF = 1) (input [3:0] c, output logic y);
always_comb y = c[CF];
endmodule
module top(input [3:0] c, output y0, output y1);
sub #(.CF(3)) u0(.c(c), .y(y0));
sub u1(.c(c), .y(y1));
endmodule

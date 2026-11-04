// § unitParamNameBindsDesign431
localparam CF = 0, XF = 4;
module child(input a, output b);
assign b = a;
endmodule
module sub(input [4:0] x, output z, output w);
assign z = ~x[CF];
child c(.a(x[XF]), .b(w));
endmodule
module top(input [4:0] x, output z, output w);
sub u(.x(x), .z(z), .w(w));
endmodule

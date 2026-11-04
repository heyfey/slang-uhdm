// § unitParamNameBindsDesign431
localparam CF = 0, XF = 1;
module child(input a, output b);
assign b = a;
endmodule
module sub(input [4:0] x, output w);
localparam CF = 0, XF = 1;
child c(.a(XF), .b(w));
endmodule
module top(input [4:0] x, output w);
sub u(.x(x), .w(w));
endmodule

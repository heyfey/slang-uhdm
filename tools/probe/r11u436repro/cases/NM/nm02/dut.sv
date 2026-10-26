// § nestedModGateUpwardNet436
module top(input a, b, output y);
wire w;
module sub;
assign w = a & b;
endmodule
sub i1();
assign y = w;
endmodule

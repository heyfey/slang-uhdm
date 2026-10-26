// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub;
and g1 (w, a, b);
endmodule
wire w;
sub i1();
assign y = w;
endmodule

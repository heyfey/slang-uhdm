// § nestedModGateUpwardNet436
module top(input a, b, output y);
logic q;
module sub;
and g1 (q, a, b);
endmodule
sub i1();
assign y = q;
endmodule

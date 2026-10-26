// § nestedModGateUpwardNet436
module top(input a, b, output [1:0] y);
module sub;
and g1 (y[0], a, b);
xor g2 (y[1], a, b);
endmodule
sub i1();
endmodule

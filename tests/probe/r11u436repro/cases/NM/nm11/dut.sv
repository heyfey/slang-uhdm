// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub;
and (y, a, b);
xor g2 (y, a, a);
endmodule
sub i1();
endmodule

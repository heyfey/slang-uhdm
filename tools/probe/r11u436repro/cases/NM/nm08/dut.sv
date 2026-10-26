// § nestedModGateUpwardNet436
module top(input [1:0] a, output y);
module sub;
and g1 (y, a[0], a[1]);
endmodule
sub i1();
endmodule

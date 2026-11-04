// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub(input c, output d);
and g1 (d, c, b);
endmodule
sub i1(.c(a), .d(y));
endmodule

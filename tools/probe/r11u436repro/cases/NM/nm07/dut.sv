// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub(input x);
and g1 (y, x, a);
endmodule
sub i1(.x(b));
endmodule

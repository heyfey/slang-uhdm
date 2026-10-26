// § nestedModGateUpwardNet436
module top(input a, b, output y);
wire t;
module sub;
not g0 (t, a);
and g1 (y, t, b);
endmodule
sub i1();
endmodule

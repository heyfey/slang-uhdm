// § nestedModGateUpwardNet436
module top(input a, b, output y, output z);
module sub;
and g1 (y, a, b);
or g2 (z, a, b);
endmodule
sub i1();
sub i2();
endmodule

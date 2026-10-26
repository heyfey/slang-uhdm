// § nestedModGateUpwardNet436
module top(input a, output y);
module sub;
not g1 (y, a);
endmodule
module sub2;
not g2 (y, a);
endmodule
sub i1();
endmodule

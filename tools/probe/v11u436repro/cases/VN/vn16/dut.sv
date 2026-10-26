// § nestedModGateUpwardNet436
module top(input a, b, output y);
parameter D = 2;
module sub;
and #(D) g1 (y, a, b);
endmodule
sub i1();
endmodule

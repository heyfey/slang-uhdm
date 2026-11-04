// § nestedModGateUpwardNet436
module top(input a, b, output y);
wire m;
module sub;
wire t;
nand g1 (t, a, b);
nand g2 (m, t, t);
endmodule
sub i1();
buf g3 (y, m);
endmodule

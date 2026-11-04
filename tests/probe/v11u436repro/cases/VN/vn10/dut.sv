// § nestedModGateUpwardNet436
module outer(input a, b, output y);
module sub;
buf g1 (y, a);
endmodule
sub i1();
endmodule
module top(input a, b, output y1, y2);
outer o1(a, b, y1);
outer o2(b, a, y2);
endmodule

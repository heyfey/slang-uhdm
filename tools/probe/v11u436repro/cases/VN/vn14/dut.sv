// § nestedModGateUpwardNet436
primitive p_and(output o, input a, input b);
table 1 1 : 1; 0 ? : 0; ? 0 : 0; endtable
endprimitive
module top(input a, b, output y);
module sub;
p_and u1 (y, a, b);
endmodule
sub i1();
endmodule

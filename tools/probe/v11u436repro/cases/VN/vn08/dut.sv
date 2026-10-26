// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub;
and g1 (y, a, b);
endmodule
assign y = a;
endmodule

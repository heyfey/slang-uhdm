// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub;
generate if (1) begin : g
and g1 (y, a, b);
end endgenerate
endmodule
sub i1();
endmodule

// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub;
and g1 (y, a, b);
endmodule
if (1) begin : gb
  sub i1();
end
endmodule

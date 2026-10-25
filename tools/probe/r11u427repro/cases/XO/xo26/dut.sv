// § xzOvLitKeepsText427
module sub #(parameter P = 4'b0)(input a, output o); assign o = a ^ P[0]; endmodule
module top(input a, output [3:0] o);
  for (genvar g = 0; g < 2; g++) begin : gb
    sub #(.P(4'b1x0z)) u(.a(a), .o(o[g]));
  end
  if (1) begin : gi
    sub #('bx) u(.a(a), .o(o[2]));
  end
  sub #(.P(4'b0000)) uc(.a(a), .o(o[3]));
endmodule

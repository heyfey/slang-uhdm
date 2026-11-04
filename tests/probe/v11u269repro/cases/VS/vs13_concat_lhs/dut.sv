// § selLhsOpFoldFresh269
module m(output wire [3:0] a, output wire [3:0] b);
  assign {a, b} = 8'h12 + 8'h01;
endmodule
module top(output wire [3:0] a, b);
  m u(.a(a), .b(b));
endmodule

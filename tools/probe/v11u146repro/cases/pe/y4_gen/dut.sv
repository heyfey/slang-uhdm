// § portExprElabDefNets146
module c(.a({b, cc}));
  input b, cc;
endmodule
module top(input x, input y);
  generate if (1) begin : g
    c u(.a({x, y}));
  end endgenerate
endmodule

// § enumCastChainKeepsInnerCast493
module top #(parameter int P = 1)(input int a, output int v);
  if (P == 1) begin : g
    assign v = int'(int'(a));
  end
endmodule

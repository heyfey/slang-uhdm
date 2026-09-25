// § genLpUintCaRhsOwnCopy148
module top(output int o);
  int v;
  for (genvar k = 0; k < 1; k++) begin : g
    localparam L = 7;
    assign v = L;
  end
  assign o = v;
endmodule

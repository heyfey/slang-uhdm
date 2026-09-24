// § sysArgUnaryWholeSpan140
module top(output int o);
  localparam logic [7:0] K = 8'h0f;
  localparam int P = $bits(~K);
  assign o = P;
endmodule

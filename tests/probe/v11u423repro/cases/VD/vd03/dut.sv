// § decUnszElabRespellKeepsM1_423
module sub(output int o);
  localparam T = 'd33;
  assign o = T + 2;
endmodule
module top(output int y);
  sub u(.o(y));
endmodule

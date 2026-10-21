// § decUnszElabRespellKeepsM1_423
module top(output int y, output int z);
  localparam T = 'd12;
  assign y = T + 1;
  always_comb z = T;
endmodule

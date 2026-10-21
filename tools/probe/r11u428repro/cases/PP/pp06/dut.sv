// § ansiLogicLeaderFollowerNet428
module m(input clk, logic [3:0] a, b, output logic o);
  assign o = a[0] ^ b[1];
endmodule
module top(input c, input [3:0] x, y, output z);
  m u(c, x, y, z);
endmodule

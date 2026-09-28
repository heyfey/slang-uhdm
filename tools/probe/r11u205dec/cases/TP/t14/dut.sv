module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  logic [2:0] q;
  t y;
  assign x[0] = s;
  assign q = s;
  assign y = s;
  assign o = x[0] ^ y ^ q[0];
endmodule

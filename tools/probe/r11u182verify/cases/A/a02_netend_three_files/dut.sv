// § tdMoveCarriesFile172
module dut import pa::*; (input logic [4:0] i, output logic o, p, q);
  s_t n0 [4];
  assign n0[2] = i;
  assign o = n0[2].y;
  m1 u1(i, p);
  m2 u2(i, q);
endmodule

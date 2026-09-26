// § tdMoveCarriesFile172
module dut import pa::*; (input logic [2:0] i, output logic o, p);
  s_t a [4];
  assign a[0] = i;
  assign o = a[0].y;
  m1 u(i, p);
endmodule

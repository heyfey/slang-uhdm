// § tdMoveCarriesFile172
module dut import pa::*; (input logic [4:0] i, output logic o);
  s_t a;
  assign a = i;
  always_comb pb::tb(a, o);
endmodule

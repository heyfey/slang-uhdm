// § tdMoveCarriesFile172
module dut import pa::*; (input logic [1:0] i, output logic o, p);
  e_t n [2];
  assign n[0] = e_t'(i);
  assign o = pb::fb(n[0]);
  assign p = n[0] == E2;
endmodule

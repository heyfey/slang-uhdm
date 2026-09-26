// § tdMoveCarriesFile172
module dut import pa::*; (input logic [4:0] i, output logic o, output logic [3:0] q);
  s_t a;
  assign a = i;
  assign o = pb::fb(a);
  assign q = pc::fc(1'b0, a);
endmodule

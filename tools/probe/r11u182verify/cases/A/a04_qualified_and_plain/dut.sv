// § tdMoveCarriesFile172
module dut (input logic [4:0] i, output logic o, p);
  pa::s_t a;
  assign a = i;
  assign o = pb::fb(a);
  assign p = pc::fc(a);
endmodule

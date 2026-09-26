// § tsMemberRootFile171
module dut import pa::*; (input logic [7:0] i, output logic [3:0] o);
  u_t x;
  assign x = i;
  assign o = x.s.a;
endmodule

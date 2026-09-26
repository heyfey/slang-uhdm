// § castUnionCloneFile171
module dut import pu::*; (input logic [7:0] i, output logic [3:0] o, output s_t s);
  u_t x;
  assign x = u_t'(i);
  assign o = x.f.hi;
  assign s = '{u: u_t'(i), v: 1'b1};
endmodule

// § castUnionCloneFile171
module dut(input logic [7:0] i, output logic [3:0] o);
  p::u_t u;
  assign u = p::u_t'(i);
  assign o = u.f.hi;
endmodule

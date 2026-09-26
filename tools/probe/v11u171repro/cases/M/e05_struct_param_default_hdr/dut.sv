// § tsMemberRootFile171
`include "h.svh"
module sub #(parameter cfg_t C = '{a: 1, b: 2}) (output logic [7:0] o);
  assign o = C;
endmodule
module dut(output logic [7:0] o, o2);
  sub #(.C('{a: 3, b: 4})) u0(o);
  sub u1(o2);
endmodule

// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the override's typedef written by a macro from an included file
`include "td.svh"
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T r;
  always_comb r = si;
  assign o = r;
endmodule
module top(output logic [1:0] c);
  `MKENUM(me_t)
  me_t p;
  sub #(.T(me_t)) v (.si(p), .o(c));
endmodule

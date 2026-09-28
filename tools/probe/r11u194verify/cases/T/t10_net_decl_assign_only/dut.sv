// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the only write of a T net is a net declaration assignment; the output port is a variable written procedurally
module sub #(parameter type T = logic) (input T si, output T so);
  wire T w = si;
  always_comb so = w;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p, q;
  sub #(.T(je_t)) v (.si(p), .so(q));
  assign c = q;
endmodule

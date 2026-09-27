// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the override names a typedef of a module enum typedef
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T r;
  always_comb r = si;
  assign o = r;
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  typedef ie_t je_t;
  je_t p;
  sub #(.T(je_t)) v (.si(p), .o(c));
endmodule

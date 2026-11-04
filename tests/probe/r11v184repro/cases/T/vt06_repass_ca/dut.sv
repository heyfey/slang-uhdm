// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a module enum re-passed through a middle module to a leaf with a whole-signal continuous assignment, beside a second override
module leaf #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module mid #(parameter type T = logic) (input T si, output T so);
  T r;
  always_comb r = si;
  leaf #(.T(T)) l (.si(r), .so(so));
endmodule
module top(output logic [1:0] c, output logic [2:0] d);
  typedef enum logic [1:0] {I0, I1} ie_t;
  typedef enum logic [2:0] {J0 = 3'd3, J1 = 3'd6} je_t;
  ie_t p, q;
  je_t x, y;
  mid #(.T(ie_t)) m (.si(p), .so(q));
  leaf #(.T(je_t)) lf (.si(x), .so(y));
  assign c = q;
  assign d = y;
endmodule

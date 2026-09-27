// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a T-typed net written by a separate continuous assignment
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  wire T w;
  assign w = si;
  always_comb o = w;
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule

// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the only continuous assignment writes two T signals through a concatenation
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T a, b;
  assign {a, b} = {si, si};
  always_comb o = a;
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule

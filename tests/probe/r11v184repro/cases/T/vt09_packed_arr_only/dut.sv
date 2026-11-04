// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the only continuous assignment writes a packed array of T
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T [1:0] r;
  assign r = {si, si};
  always_comb o = r[0];
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule

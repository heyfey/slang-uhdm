// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a continuous assignment writes a packed array OF T, and a concatenation of T signals
module sub #(parameter type T = logic) (input T si, output logic [3:0] o, output logic [3:0] o2);
  T [1:0] r;
  T a, b;
  assign r = {si, si};
  assign {a, b} = {si, si};
  assign o = r;
  assign o2 = {a, b};
endmodule
module top(output logic [3:0] c, output logic [3:0] d);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c), .o2(d));
endmodule

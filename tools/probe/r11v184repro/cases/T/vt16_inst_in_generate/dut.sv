// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the overridden child instantiated inside a generate block of the parent, with a generate-local enum and a module enum
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T r;
  always_comb r = si;
  assign o = r;
endmodule
module top #(parameter bit P = 1) (output logic [1:0] c, output logic [1:0] d);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  if (P) begin : g
    sub #(.T(ie_t)) v (.si(p), .o(c));
  end
  sub #(.T(ie_t)) w (.si(p), .o(d));
endmodule

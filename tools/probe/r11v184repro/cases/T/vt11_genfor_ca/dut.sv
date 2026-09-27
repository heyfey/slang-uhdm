// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the whole-signal continuous assignment inside a generate-for body, writing a T signal declared in the block
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  for (genvar i = 0; i < 1; i++) begin : gf
    T r;
    assign r = si;
    always_comb o = r;
  end
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule

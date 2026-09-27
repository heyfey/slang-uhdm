// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v (control): a generate block's continuous assignment writing a select of a T signal, and a procedural whole write
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T r, q;
  if (1) begin : g
    assign r[0] = si[0];
    always_comb q = si;
  end
  always_comb o = q;
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule

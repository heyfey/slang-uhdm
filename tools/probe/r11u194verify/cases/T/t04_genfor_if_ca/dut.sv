// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the whole-signal continuous assignment sits in an if-generate inside a generate-for body of the child (two levels down), writing a module-level T variable
module sub #(parameter type T = logic) (input T si, output T so);
  T r;
  for (genvar i = 0; i < 1; i++) begin : gl
    if (i == 0) begin : gi
      assign r = si;
    end
  end
  assign so = r;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1, I2} ie_t;
  ie_t p, q;
  sub #(.T(ie_t)) v (.si(p), .so(q));
  assign c = q;
endmodule

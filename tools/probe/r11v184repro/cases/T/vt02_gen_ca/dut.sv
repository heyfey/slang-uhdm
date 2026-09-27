// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the whole-signal continuous assignment sits inside a generate block of the child
module sub #(parameter type T = logic) (input T si, output T so);
  if (1) begin : g
    assign so = si;
  end
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p, q;
  sub #(.T(ie_t)) v (.si(p), .so(q));
  assign c = q;
endmodule

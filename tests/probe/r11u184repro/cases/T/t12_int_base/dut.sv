// § tpEnumCopyAtTypedef184: an enum of int base passed as a type parameter
module sub #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module top(output int c);
  typedef enum int {I0, I1 = 7} ie_t;
  ie_t p, q;
  sub #(.T(ie_t)) v (.si(p), .so(q));
  assign c = q;
endmodule

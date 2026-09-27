// § tpEnumCopyAtTypedef184: the type-parameter enum copy, parented or not by the child body (the continuous-assignment target distinguisher)
module sub #(parameter type T = logic) (input T si);
endmodule
module top();
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p));
endmodule

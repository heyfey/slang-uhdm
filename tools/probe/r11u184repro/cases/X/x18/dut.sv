// § tpEnumCopyAtTypedef184: the type-parameter enum copy, parented or not by the child body (the continuous-assignment target distinguisher)
module sub #(parameter type T = logic, parameter type U = logic [1:0]) (input T si, output logic [1:0] so);
  U r;
  assign r = si;
  assign so = r;
endmodule
module top();
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  logic [1:0] q;
  sub #(.T(ie_t)) v (.si(p), .so(q));
endmodule

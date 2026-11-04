// § pkgQualPatConnSpan267
package qp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
endpackage
package pp;
  parameter qp::req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h9};
  parameter qp::req_t REQ_OTHER = '{a: 1'b0, w: 4'h1};
endpackage
module pm (input qp::req_t s, input qp::req_t t, output logic o);
  assign o = s.a ^ t.a;
endmodule
module top(output logic o);
  pm u_a(.s(pp::REQ_DEFAULT), .t(pp::REQ_OTHER), .o(o));
endmodule

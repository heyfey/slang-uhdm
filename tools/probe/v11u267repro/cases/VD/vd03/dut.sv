// § pkgQualPatConnSpan267
package pp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{default: '0};
endpackage
module pm (input pp::req_t s, output logic o);
  assign o = s.a;
endmodule
module top(output logic o);
  pm u_a(.s(pp::REQ_DEFAULT), .o(o));
endmodule

// § pkgQualPatConnSpan267
`define DEF pp::REQ_DEFAULT
package pp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h3};
endpackage
module pm (input pp::req_t s, output logic o);
  assign o = s.a;
endmodule
module top(output logic o, output logic o2);
  pm u_a(.s(`DEF), .o(o));
  pm u_b(`DEF, o2);
endmodule

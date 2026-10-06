// § pkgQualPatConnSpan267
package pp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h3};
endpackage
module pm (input pp::req_t r, output logic o);
  assign o = r.a;
endmodule
module top(output logic o, output logic o2);
  pm u_pm(.r((pp::REQ_DEFAULT)), .o(o));
  pm u_pm2(.r(pp::REQ_DEFAULT), .o(o2));
endmodule

// § pkgQualPatConnSpan267
package pp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h3};
endpackage
interface ifc (input pp::req_t r);
endinterface
module top;
  ifc u_i(.r(pp::REQ_DEFAULT));
endmodule

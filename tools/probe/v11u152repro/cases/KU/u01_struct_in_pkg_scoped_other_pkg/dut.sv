// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
package gp;
  typedef struct packed {
    fp::cf_t [1:0] at;
    logic z;
  } g_t;
endpackage
module top(input gp::g_t a, output gp::g_t b);
  assign b = a;
endmodule

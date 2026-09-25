// § pkgElemMemberPatNoLoc152
package gp;
  typedef struct packed { logic a; logic b; } cf_t;
  typedef struct packed {
    gp::cf_t [3:0] at;
    logic x;
  } tf_t;
endpackage
module top(input gp::tf_t a, output gp::tf_t b);
  assign b = a;
endmodule

// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
package gp;
typedef union packed {
  fp::cf_t [3:0][7:0] at;
} tf_t;
endpackage
module top(input gp::tf_t a, output gp::tf_t b);
  assign b = a;
endmodule

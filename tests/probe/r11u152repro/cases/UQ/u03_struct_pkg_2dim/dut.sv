// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
typedef struct packed {
  fp::cf_t [3:0][7:0] at;
} tf_t;
module top(input tf_t a, output tf_t b);
  assign b = a;
endmodule

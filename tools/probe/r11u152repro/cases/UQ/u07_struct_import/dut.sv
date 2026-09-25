// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
import fp::*;
typedef struct packed {
  cf_t [3:0] at;
  logic x;
} tf_t;
module top(input tf_t a, output tf_t b);
  assign b = a;
endmodule

// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
module top(input logic [15:0] a, output logic [15:0] b);
  typedef struct packed {
    fp::cf_t [3:0] at;
  } tf_t;
  tf_t q;
  assign q = a[7:0];
  assign b = q;
endmodule

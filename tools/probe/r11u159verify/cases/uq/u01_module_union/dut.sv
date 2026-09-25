// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  typedef union packed { fp::cf_t [1:0] a; logic [3:0] b; } u_t;
  u_t v;
  assign v.b = i;
  assign o = v.a;
endmodule

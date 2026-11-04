// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; } cf_t;
endpackage
package gp;
  typedef struct packed { fp::cf_t [1:0][1:0][1:0] at; } t_t;
endpackage
module top(input gp::t_t a, output logic [7:0] o);
  assign o = a;
endmodule

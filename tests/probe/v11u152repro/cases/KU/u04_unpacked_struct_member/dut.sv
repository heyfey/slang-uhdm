// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
module top(output logic o);
  typedef struct {
    fp::cf_t [1:0] at;
  } t_t;
  t_t v;
  assign v.at = '0;
  assign o = ^v.at;
endmodule

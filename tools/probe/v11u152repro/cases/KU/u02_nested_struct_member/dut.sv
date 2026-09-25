// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
module top(input logic [9:0] a, output logic o);
  typedef struct packed {
    struct packed {
      fp::cf_t [1:0] at;
    } inner;
    logic q;
  } t_t;
  t_t v;
  assign v = a[4:0];
  assign o = ^v;
endmodule

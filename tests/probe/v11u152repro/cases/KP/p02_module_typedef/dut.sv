// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  typedef s_t [2:0] a_t;
  a_t a;
  assign a = i;
  assign x = int'(a);
endmodule

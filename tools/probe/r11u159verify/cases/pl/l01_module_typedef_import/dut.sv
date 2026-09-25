// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  typedef s_t [2:0] a_t;
  a_t v;
  assign v = i;
  assign x = int'(v);
endmodule

// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top (input logic [5:0] i, output int x);
  import pk::s_t;
  s_t [2:0] a;
  assign a = i;
  assign x = int'(a);
endmodule

// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (input s_t [2:0] a, output int x);
  assign x = int'(a);
endmodule

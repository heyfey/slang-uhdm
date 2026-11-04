// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
  typedef s_t [2:0] a_t;
endpackage
module top (input pk::a_t i, output int x);
  assign x = int'(i);
endmodule

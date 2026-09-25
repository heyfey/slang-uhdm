// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (output int x);
  s_t [2:0] w;
  assign w = '0;
  assign x = int'(w);
endmodule

// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (output int x);
  localparam s_t [1:0] P = '0;
  assign x = int'(P);
endmodule

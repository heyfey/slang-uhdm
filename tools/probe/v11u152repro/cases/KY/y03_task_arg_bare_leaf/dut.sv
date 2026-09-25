// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  task automatic t(input s_t [2:0] v, output int r);
    r = int'(v);
  endtask
  initial begin int q; t(i, q); end
  assign x = 0;
endmodule

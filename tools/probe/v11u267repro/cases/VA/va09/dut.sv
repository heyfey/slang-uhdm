// § caFoldDelayRefKeepsUnparented267v
package fp;
  typedef struct packed { logic [7:0] q; logic e; } fld_t;
endpackage
module fc import fp::*; #(parameter int W = 8, parameter int D = 2) (output fld_t o);
  fld_t s;
  assign #(D) s.q = {W{1'b1}};
  assign #D s.e = 1'b0;
  assign o = s;
endmodule
module top(output fp::fld_t o);
  fc u_fc(.o(o));
endmodule

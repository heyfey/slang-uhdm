// § caFoldParentUnboundLhs267
package fp;
  typedef struct packed { logic [7:0] q; logic e; } fld_t;
endpackage
module fc import fp::*; #(parameter int W = 2) (output fld_t o);
  assign o.q[3:0] = {W{2'b10}};
  assign o.q[7:4] = 4'h0;
  assign o.e = 1'b1;
endmodule
module top(output fp::fld_t o);
  fc u_fc(.o(o));
endmodule

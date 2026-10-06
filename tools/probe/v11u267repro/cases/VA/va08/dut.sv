// § caFoldParentUnboundLhs267
package fp;
  typedef struct packed { logic [7:0] q; logic e; } fld_t;
endpackage
module fc import fp::*; #(parameter int W = 8) (output fld_t o);
  fld_t s;
  assign s.q = {W{1'b1}}, s.e = 1'b0;
  assign o = s;
endmodule
module top(output fp::fld_t o);
  fc #(.W(8)) u_fc(.o(o));
  fc #(.W(8)) u_fc2(.o());
endmodule

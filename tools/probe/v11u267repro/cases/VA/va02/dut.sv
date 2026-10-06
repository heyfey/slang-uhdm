// § caFoldParentUnboundLhs267
package fp;
  typedef struct packed { logic [7:0] q; logic [3:0] r; } fld_t;
endpackage
module fc import fp::*; #(parameter int P = 3) (output fld_t o);
  assign o.q = P + 8'd1;
  assign o.r = (P > 2) ? 4'h5 : 4'ha;
endmodule
module top(output fp::fld_t o, output fp::fld_t o2);
  fc u_fc(.o(o));
  fc #(.P(1)) u_fc2(.o(o2));
endmodule

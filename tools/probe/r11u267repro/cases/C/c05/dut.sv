// § caFoldParentUnboundLhs267
package pk;
  localparam int N = 3;
  typedef struct packed { logic [5:0] a; } s_t;
endpackage
module m import pk::*; (output s_t o);
  assign o.a = {N{2'b01}};
endmodule
module top(output pk::s_t o);
  m u(.o(o));
endmodule

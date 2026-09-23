// logic [69:0] member + scoped cont-assign read
package q2;
  typedef struct packed { logic [3:0] pad; logic [69:0] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 70'h1, cfg: 2'b11 };
endpackage
module top(output logic [69:0] o);
  assign o = q2::IMPL.m;
endmodule

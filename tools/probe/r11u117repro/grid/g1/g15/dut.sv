// nested struct member, q2::IMPL.s.x in module localparam
package q2;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: '{x: 4'h1, y: 4'h2}, cfg: 2'b11 };
endpackage
module top(output logic [3:0] o);
  localparam logic [3:0] V = q2::IMPL.s.x;
  assign o = V;
endmodule

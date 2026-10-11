// § caStructParamModSharesPaOperand289
package q2;
  typedef struct packed { logic [3:0] x; logic [7:0] y; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: '{ x: 4'h3, y: {4'h1, 4'h2} } };
endpackage
module top import q2::*; (output logic [7:0] o);
  assign o = IMPL.s.y;
endmodule

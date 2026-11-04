// § caStructParamModSharesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: {4'h1, 4'h2}, cfg: 2'b11 };
endpackage
module sub #(parameter int W = 4) (output logic [W-1:0] o);
  import q2::*;
  assign o = IMPL.pad;
endmodule
module top (output logic [15:0] o, output logic [3:0] p);
  sub #(16) u (.o(o));
  sub #(4) v (.o(p));
endmodule

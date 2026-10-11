// § caStructParamModClonesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; } impl_t;
endpackage
module top (output logic [7:0] o, output logic [7:0] p);
  localparam q2::impl_t IMPL = '{ pad: 4'h9, a: {4'h1, 4'h2}, cfg: 2'b11 };
  assign o = IMPL.a;
  assign p = IMPL.a;
endmodule

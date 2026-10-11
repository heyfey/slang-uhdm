// § caStructParamModClonesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; logic [11:0] w; } impl_t;
endpackage
module sub #(parameter q2::impl_t IMPL = '{ pad: 4'h9, a: 8'b1010_0110, cfg: 2'b11, w: 12'hABC }) (output logic [5:0] o);
  assign o = IMPL.w;
endmodule
module top (output logic [5:0] o, output logic [5:0] p);
  sub u0 (.o(o));
  sub #(.IMPL('{ pad: 4'h1, a: 8'b0000_0110, cfg: 2'b01, w: 12'h123 })) u1 (.o(p));
endmodule

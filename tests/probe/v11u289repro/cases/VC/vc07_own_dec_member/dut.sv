// § caStructParamModClonesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; logic [11:0] w; } impl_t;
endpackage
module top (output logic [3:0] o, output logic [15:0] p);
  localparam q2::impl_t IMPL = '{ pad: 4'd9, a: 8'd200, cfg: 2'd3, w: 12'd2748 };
  assign o = IMPL.a;
  assign p = IMPL.w;
endmodule

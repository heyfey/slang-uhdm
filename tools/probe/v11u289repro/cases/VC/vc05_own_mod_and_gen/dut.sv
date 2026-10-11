// § caStructParamModClonesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; logic [11:0] w; } impl_t;
endpackage
module top (output logic [5:0] o, output logic [15:0] p);
  localparam q2::impl_t IMPL = '{ pad: 4'h9, a: 8'b1010_0110, cfg: 2'b11, w: 12'hABC };
  if (1) begin : g
    assign p = IMPL.w;
  end
  assign o = IMPL.w;
endmodule

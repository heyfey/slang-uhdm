// § caDelayNameRefKeepsOperand289v
package pd; parameter int PD = 2; endpackage
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; logic [11:0] w; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: 8'b1010_0110, cfg: 2'b11, w: 12'hABC };
endpackage
module top import q2::*; (output logic [3:0] o);
  assign #pd::PD o = IMPL.a;
endmodule

// § caStructParamModSharesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; logic [11:0] w; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: 8'b1010_0110, cfg: 2'b11, w: 12'hABC };
endpackage
package q3;
  localparam q2::impl_t IMPL3 = '{ pad: 4'h3, a: 8'b0000_1111, cfg: 2'b01, w: 12'h0F0 };
endpackage
module top import q2::*; import q3::*; (output logic [5:0] o, output logic [5:0] p);
  assign o = IMPL.w;
  assign p = IMPL3.w;
endmodule

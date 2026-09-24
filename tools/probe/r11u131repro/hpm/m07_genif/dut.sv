// § cstParamMemberBaseSpan131
package p; typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t; localparam cfg_t C = '{XLEN: 32, VLEN: 8}; endpackage
module top #(parameter p::cfg_t Cfg = p::C) (output logic o); if (Cfg.XLEN == 32) begin : g assign o = 1'b1; end else begin : h assign o = 1'b0; end endmodule

// § cstParamMemberBaseSpan131
package p; typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t; localparam cfg_t C = '{XLEN: 32, VLEN: 8}; endpackage
module top #(parameter p::cfg_t Cfg = p::C) (output logic [Cfg.XLEN-1:0] o); assign o = '0; endmodule

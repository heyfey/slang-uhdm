// § cstParamMemberBaseSpan131
package p; typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t; localparam cfg_t C = '{XLEN: 32, VLEN: 8}; endpackage
module top #(parameter p::cfg_t Cfg = p::C) (output int o); assign o = Cfg.XLEN; endmodule

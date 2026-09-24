// § cstParamMemberBaseSpan131
package p; typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t; localparam cfg_t C = '{XLEN: 32, VLEN: 8}; endpackage
module sub #(parameter p::cfg_t Cfg = p::C) (); localparam int W = Cfg.VLEN; logic [W-1:0] q; endmodule
module top (); sub u(); endmodule

// § cstParamMemberBaseSpan131
package p; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; int unsigned X; } cfg_t; localparam cfg_t C = '{BUS: '{DAT: 16}, X: 4}; endpackage
module top #(parameter p::cfg_t Cfg = p::C) (); localparam int W = Cfg.BUS.DAT; logic [W-1:0] q; endmodule

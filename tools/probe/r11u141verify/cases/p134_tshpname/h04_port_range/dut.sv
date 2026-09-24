// § tsHierPathElemNoName134
// case h04: an output port ranged by a package-struct parameter member, top module
package cp;
  typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
  localparam cfg_t Def = '{W: 32'd6, D: 32'd2};
endpackage
module top #(parameter cp::cfg_t Cfg = cp::Def) (input logic [Cfg.W-1:0] i, output logic [Cfg.W-1:0] o);
  assign o = i;
endmodule

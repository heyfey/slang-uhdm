// § tsHierPathElemNoName134
// case h05: a module-local vector typedef ranged by a struct-parameter member
package cp;
  typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
  localparam cfg_t Def = '{W: 32'd6, D: 32'd2};
endpackage
module top #(parameter cp::cfg_t Cfg = cp::Def) (input logic [5:0] i, output logic [5:0] o);
  typedef logic [Cfg.W-1:0] w_t;
  w_t x;
  assign x = i;
  assign o = x;
endmodule

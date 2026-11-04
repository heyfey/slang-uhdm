// § tsHierPathElemNoName134
// case h06: an interface signal ranged by a struct-parameter member, interface instantiated
package cp;
  typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
  localparam cfg_t Def = '{W: 32'd6, D: 32'd2};
endpackage
interface ifc #(parameter cp::cfg_t Cfg = cp::Def);
  logic [Cfg.D-1:0] d;
endinterface
module top(output logic [1:0] o);
  ifc u();
  assign o = u.d;
endmodule

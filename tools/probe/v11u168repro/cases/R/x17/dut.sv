// § rangeHierPathNoFullName168
package p;
  typedef struct packed { int unsigned W; logic H; } cfg_t;
  localparam cfg_t CFG_DEF = '{W: 3, H: 1'b0};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  wire dw [0:CFG.W];
  wire [3:0] dv [CFG.W:1];
  logic dl [CFG.W];
endinterface
module top (output logic o);
  bus_if b ();
  assign o = b.dw[1];
endmodule

// § structParamBoundAtPatternLeaf168 (r11u164 residue HR h05)
package p;
  typedef struct packed { int unsigned W; logic H; } cfg_t;
  localparam cfg_t CFG_DEF = '{W: 3, H: 1'b0};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic [CFG.W:0] dly;
endinterface
module top (output logic o);
  bus_if b ();
  assign o = b.dly[1];
endmodule

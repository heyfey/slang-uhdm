// § structParamBoundAtPatternLeaf168 (r11u164 residue HR h02)
package p;
  typedef struct packed { int unsigned W; logic H; } cfg_t;
  localparam cfg_t CFG_DEF = '{W: 3, H: 1'b0};
endpackage
module top #(parameter p::cfg_t CFG = p::CFG_DEF) (output logic [CFG.W-1:0] o);
  logic [CFG.W-1:0] v;
  assign o = v;
endmodule

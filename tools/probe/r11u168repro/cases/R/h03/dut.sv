// § structParamBoundAtPatternLeaf168 (r11u164 residue HR h03)
package p;
  typedef struct packed { int unsigned W; logic H; } cfg_t;
  localparam cfg_t CFG_DEF = '{W: 3, H: 1'b0};
endpackage
module top #(parameter p::cfg_t CFG = p::CFG_DEF) (output logic o);
  logic v [0:CFG.W];
  assign v[0] = 1'b1;
  assign o = v[0];
endmodule

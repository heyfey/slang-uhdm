// § structParamBoundAtPatternLeaf168
package p;
  typedef struct packed { int unsigned W; int unsigned H; } cfg_t;
  localparam cfg_t CFG_DEF = '{W: 3, default: 1};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic dly [0:CFG.W];
  assign dly[0] = 1'b1;
endinterface
module top (output logic o);
  bus_if b ();
  assign o = b.dly[1];
endmodule

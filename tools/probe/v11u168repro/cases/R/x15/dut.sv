// § structParamBoundAtPatternLeaf168
package p;
  typedef struct packed { int unsigned W; logic H; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{W: 3, H: 1'b0});
  logic dly [0:CFG.W];
  logic [7:0] dv [CFG.W:0];
  assign dly[0] = 1'b1;
endinterface
module top (output logic o);
  bus_if b ();
  bus_if #(.CFG('{W: 6, H: 1'b1})) c ();
  assign o = b.dly[1] ^ c.dly[2];
endmodule

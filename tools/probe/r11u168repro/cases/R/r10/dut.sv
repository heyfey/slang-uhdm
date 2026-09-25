// § structParamBoundAtPatternLeaf168
package p;
  typedef struct packed { int unsigned DLY; logic HLD; } hsk_t;
  typedef struct packed { hsk_t HSK; int unsigned DAT; } cfg_t;
  localparam cfg_t CFG_DEF = '{HSK: '{1, 1'b0}, DAT: 32};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic dly [CFG.HSK.DLY:0];
  assign dly[0] = 1'b1;
endinterface
module top #(parameter p::cfg_t TC = '{HSK: '{2, 1'b0}, DAT: 16}) (output logic o);
  bus_if #(TC) b ();
  assign o = b.dly[1];
endmodule

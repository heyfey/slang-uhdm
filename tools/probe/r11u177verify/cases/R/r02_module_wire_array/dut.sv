// § rangeHierPathNoFullName168 § structParamBoundAtPatternLeaf168
package p;
  typedef struct packed { int unsigned DLY; logic HLD; } hsk_t;
  typedef struct packed { hsk_t HSK; int unsigned DAT; } cfg_t;
  localparam cfg_t CFG_DEF = '{HSK: '{2, 1'b0}, DAT: 32};
endpackage
module sub #(parameter p::cfg_t CFG = p::CFG_DEF) (output logic o);
  wire dly [0:CFG.HSK.DLY];
  assign dly[0] = 1'b1;
  assign o = dly[0];
endmodule
module top (output logic o);
  sub u (.o(o));
endmodule

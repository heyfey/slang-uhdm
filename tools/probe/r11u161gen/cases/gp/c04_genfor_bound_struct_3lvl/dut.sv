// r11u161 gen path: gen-for bound reading a 3-level struct-parameter field in an interface (SEL, GenForStructParamBound shape)
package p;
  typedef struct packed { int unsigned DLY; logic HLD; } hsk_t;
  typedef struct packed { hsk_t HSK; int unsigned DAT; } cfg_t;
  localparam cfg_t CFG_DEF = '{HSK: '{2, 1'b0}, DAT: 32};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic dly [0:3];
  assign dly[0] = 1'b1;
  for (genvar i = 1; i <= CFG.HSK.DLY; i++) begin : g
    assign dly[i] = dly[i-1];
  end
endinterface
module top (output logic o);
  bus_if b ();
  assign o = b.dly[1];
endmodule

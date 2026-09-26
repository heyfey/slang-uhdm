// § structParamBoundAtPatternLeaf168 § memLeftFormalArgLoc169 § memLeftSliceUnlocated169
package p;
  typedef struct packed { int unsigned W; int unsigned H; } cfg_t;
  function automatic cfg_t mk(int unsigned x);
    cfg_t c;
    c.W = x;
    c.H = x * 2;
    return c;
  endfunction
  localparam cfg_t CFG_DEF = mk(3);
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic dly [0:CFG.W];
  logic hld [0:CFG.H];
  assign dly[0] = 1'b1;
  assign hld[0] = 1'b1;
endinterface
module top (output logic o);
  bus_if b ();
  assign o = b.dly[1] & b.hld[1];
endmodule

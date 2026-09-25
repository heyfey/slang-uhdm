// § rangeHierPathNoFullName168
package p;
  typedef struct packed { int unsigned W; logic H; } cfg_t;
  localparam cfg_t CFG_DEF = '{W: 3, H: 1'b0};
endpackage
module m #(parameter p::cfg_t CFG = p::CFG_DEF) (output logic o);
  logic dly [0:CFG.W];
  wire  dw  [0:CFG.W];
  assign dly[0] = 1'b1;
  assign o = dly[0];
endmodule
module top (output logic o);
  m u (.o(o));
endmodule

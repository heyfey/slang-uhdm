// § ppMacroBodyLines160
`define ESC_DRV(v) \
  assign \bus[0]  = v; \
  assign \bus[1]  = ~v;
module top (input logic a, output logic o);
  wire \bus[0] , \bus[1] ;
  `ESC_DRV(a)
  assign o = \bus[0]  ^ \bus[1] ;
endmodule

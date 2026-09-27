// § macroPathTokSpans183
`define DRV(IF, V) \
  assign IF.data = V;
interface bif;
  logic [3:0] data;
endinterface
module m(bif bi);
  `DRV(bi, 4'h3)
endmodule
module top;
  bif b();
  m u(.bi(b));
endmodule

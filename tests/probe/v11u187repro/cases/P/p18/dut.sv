// § macroIfacePathTokSpans183 (included macro, generate loop, operation index)
`include "m.svh"
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  `tie(bit_field_if)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule

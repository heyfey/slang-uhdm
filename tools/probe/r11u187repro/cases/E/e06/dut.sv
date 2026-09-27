// § macroIfacePathTokSpans183 (the whole path in the macro body: control)
`define tie assign bit_field_if.read_data[1] = 1'b0;
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  `tie
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule

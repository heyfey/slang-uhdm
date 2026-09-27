// § macroIfacePathTokSpans183 (nested macros)
`define inner(RIF) RIF.read_data[0]
`define tie(RIF) \
    assign `inner(RIF) = 1'b0;
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

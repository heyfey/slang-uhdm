// § macroIfacePathTokSpans183 (the index from a macro argument)
`define tie(RIF, I) \
    assign RIF.read_data[I] = 1'b0;
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  `tie(bit_field_if, 2)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule

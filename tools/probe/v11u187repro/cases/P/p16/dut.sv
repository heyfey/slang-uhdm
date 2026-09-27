// § macroIfacePathTokSpans183 (spaces around the dot, array of interfaces)
`define tie(RIF) \
    assign RIF . read_data [ 1 ] = 1'b0;
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

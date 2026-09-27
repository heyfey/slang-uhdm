// § macroIfacePathTokSpans183 (the whole path from one macro argument)
`define tie(P) \
    assign P[1] = 1'b0;
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  `tie(bit_field_if.read_data)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule

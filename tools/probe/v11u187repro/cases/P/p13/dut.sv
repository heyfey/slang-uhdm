// § macroIfacePathTokSpans183 (member from an argument, base in the body)
`define tie(M) \
    assign bit_field_if.M[3] = 1'b1;
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  `tie(read_data)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule

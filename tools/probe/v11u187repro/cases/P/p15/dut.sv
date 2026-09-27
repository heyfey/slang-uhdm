// § macroIfacePathTokSpans183 (a two-dimensional member, modport port)
`define tie(RIF) \
    assign RIF.rd[1][0] = 1'b0;
interface bif;
  logic [1:0][3:0] rd;
  modport mp(output rd);
endinterface
module m(bif.mp bit_field_if);
  `tie(bit_field_if)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule

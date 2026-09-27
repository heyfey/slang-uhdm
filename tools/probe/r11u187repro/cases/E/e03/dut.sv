// § macroIfacePathTokSpans183
`define rd(RIF, O) \
    assign O = RIF.read_data[2];
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if, output logic o);
  `rd(bit_field_if, o)
endmodule
module top(output logic o);
  bif b();
  m u(.bit_field_if(b), .o(o));
endmodule

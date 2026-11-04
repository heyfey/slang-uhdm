// § macroIfaceRangeSelBaseTok256 (a modport port in a two-level generate)
`define conn(FIF, LSB) \
  assign FIF.read_data[LSB+:2] = x[LSB+:2];
interface bif; logic [7:0] read_data; modport mp(output read_data); endinterface
module m(bif.mp bit_field_if); logic [7:0] x;
  for (genvar i = 0; i < 2; i++) begin : g1
    for (genvar j = 0; j < 2; j++) begin : g2
      `conn(bit_field_if, i*4+j*2)
    end
  end
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

// § macroIpsBaseStreamAbstain256v (a sliced right-to-left streaming target in a macro body)
`define wr(FIF) \
  always_comb {<<4{FIF.read_data[7:0]}} = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [7:0] x;
  `wr(bit_field_if)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

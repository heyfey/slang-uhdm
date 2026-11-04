// § lvStreamBaseKeepsActual258 (a range-select streaming target in a macro body (macroIpsBaseStreamAbstain256v's shape, a control))
`define wr(FIF) \
  always_comb {>>{FIF.read_data[3:0]}} = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `wr(bit_field_if)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

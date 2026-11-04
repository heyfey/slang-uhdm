// § lvStreamBaseKeepsActual258 (a macro-body bit-select streaming target inside an if-generate)
`define wr(FIF) \
  always_comb {>>{FIF.read_data[3]}} = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m #(parameter P = 1) (bif bit_field_if); logic x;
  if (P == 1) begin : gi
    `wr(bit_field_if)
  end
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

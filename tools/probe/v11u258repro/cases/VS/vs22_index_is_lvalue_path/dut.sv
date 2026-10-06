// § lvStreamBaseKeepsActual258 (a streaming target whose index is another interface member path with a select)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic x;
  always_comb {>>{bit_field_if.read_data[bit_field_if.wr_data[2:0]]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

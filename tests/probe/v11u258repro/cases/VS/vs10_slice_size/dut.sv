// § lvStreamBaseKeepsActual258 (a right-to-left stream with a slice size over an interface path and a bit select)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bit_field_if); logic [8:0] x;
  always_comb {<< 4 {bit_field_if.read_data[7:0], bit_field_if.wr_data[2]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

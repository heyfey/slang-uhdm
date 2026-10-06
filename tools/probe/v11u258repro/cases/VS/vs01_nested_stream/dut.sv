// § lvStreamBaseKeepsActual258 (a nested streaming target: an interface range select inside an inner stream inside the outer)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bit_field_if); logic [7:0] x; logic [3:0] z;
  always_comb {>>{ {<<{bit_field_if.read_data[3:0]}}, z }} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

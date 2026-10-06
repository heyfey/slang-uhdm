// § lvStreamBaseKeepsActual258 (parameter part-select bounds and an indexed part select width in the target)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m #(parameter int W = 4)(bif bit_field_if); logic [W-1:0] x; logic [1:0] z;
  localparam int LO = 1;
  always_comb {>>{bit_field_if.read_data[W-1:0], bit_field_if.wr_data[LO+:2]}} = {x, z};
endmodule
module top; bif b(); m #(.W(3)) u(.bit_field_if(b)); endmodule

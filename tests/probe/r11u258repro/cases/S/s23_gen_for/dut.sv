// § lvStreamBaseKeepsActual258 (an interface range select streaming target in a for-generate, two levels)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 1; j++) begin : h
      always_comb {>>{bit_field_if.read_data[i*4+:4]}} = x;
    end
  end
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

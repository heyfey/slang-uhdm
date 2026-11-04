// § lvStreamBaseKeepsActual258 (a genvar bit index and a genvar-based part select on an interface path in a for-generate)
interface bif; logic [7:0] read_data; endinterface
module m(bif bit_field_if); logic [1:0] x [4];
  for (genvar g = 0; g < 4; g++) begin : gb
    always_comb {>>{bit_field_if.read_data[g], bit_field_if.read_data[g+4]}} = x[g];
  end
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

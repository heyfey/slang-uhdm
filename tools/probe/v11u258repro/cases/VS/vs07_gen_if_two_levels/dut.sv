// § lvStreamBaseKeepsActual258 (a streaming target two generate levels down, instance depth 2)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bit_field_if); logic [3:0] x;
  for (genvar g = 0; g < 2; g++) begin : ga
    if (g == 0) begin : gi
      always_comb {>>{bit_field_if.read_data[3:0]}} = x;
    end
  end
endmodule
module mid(bif q); m u(.bit_field_if(q)); endmodule
module top; bif b(); mid w(.q(b)); endmodule

// § unitVarNestedScopeAbstain418v
logic [1:0] g = 2'b10;
module top (output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : b
    assign o[i] = g[i];
  end
endmodule

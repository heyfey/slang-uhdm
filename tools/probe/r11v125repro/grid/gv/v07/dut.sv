// § genvarParamLoopVarLine125
module top(input logic [3:0] a, output logic [3:0] o);
  for (genvar
       i = 0; i < 4; i++) begin : g
    assign o[i] = a[i];
  end
endmodule

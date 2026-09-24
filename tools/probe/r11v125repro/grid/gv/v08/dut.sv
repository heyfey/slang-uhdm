// § genvarParamLoopVarLine125
module top(input logic [7:0] a, output logic [7:0] o);
  genvar i, j;
  for (i = 0; i < 2; i++)
    for (j = 0; j < 2; j++)
      for (genvar k = 0; k < 2; k++) begin : w
        assign o[i*4+j*2+k] = a[i*4+j*2+k];
      end
endmodule

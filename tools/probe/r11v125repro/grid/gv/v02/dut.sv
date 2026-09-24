// § genvarParamLoopVarLine125
module top(input logic [7:0] a, output logic [7:0] o);
  genvar i, j;
  generate
    for (i = 0; i < 2; i++) begin : g
      for (j = 0;
           j < 4; j++) begin : h
        assign o[i*4+j] = a[i*4+j];
      end
    end
  endgenerate
endmodule

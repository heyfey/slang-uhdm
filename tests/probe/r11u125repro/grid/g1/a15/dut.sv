// § genvarParamLoopVarLine125
module top(output [5:0] o);
  genvar i, j, k;
  for (i = 0; i < 2; i = i + 1)
    for (j = 0; j < 1; j = j + 1)
      for (k = 0; k < 3; k = k + 1) begin : W
        assign o[i*3+k] = 1'b1;
      end
endmodule

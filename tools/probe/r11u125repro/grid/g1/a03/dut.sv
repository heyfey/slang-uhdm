// § genvarParamLoopVarLine125
module top(output [3:0] o);
  genvar i, j;
  for (i = 0; i < 2; i = i + 1)
    for (j = 0; j < 2; j = j + 1) begin : W
      assign o[i*2+j] = 1'b1;
    end
endmodule

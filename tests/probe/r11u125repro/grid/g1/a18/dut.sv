// § genvarParamLoopVarLine125
module top(output [3:0] o);
  genvar i;
  generate
    for (i = 0; i < 2; i = i + 1) begin : outer
      genvar j;
      for (j = 0; j < 2; j = j + 1)
        assign o[i*2+j] = 1'b1;
    end
  endgenerate
endmodule

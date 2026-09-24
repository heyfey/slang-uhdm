// § genvarParamLoopVarLine125
module top(output [3:0] o);
  genvar i;
  for (i = 0; i < 4; i = i + 1)
    if (i > 1) begin : h
      assign o[i] = 1'b1;
    end else begin : l
      assign o[i] = 1'b0;
    end
endmodule

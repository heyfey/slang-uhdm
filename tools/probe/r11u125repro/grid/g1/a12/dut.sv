// § genvarParamLoopVarLine125
module top(output [3:0] o);
  genvar i;
  for (i = 0; i < 4; i = i + 1)
  begin : g
    assign o[i] = 1'b1;
  end
endmodule

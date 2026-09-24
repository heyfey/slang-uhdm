// § genvarParamLoopVarLine125
module top(output [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      assign o[i*2+j] = 1'b1;
    end
  end
endmodule

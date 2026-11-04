// § genvarParamFile125
module top(output [3:0] o);
  genvar i;
  generate
  for (i = 0; i < 4; i = i + 1)
    assign o[i] = 1'b1;
  endgenerate
endmodule

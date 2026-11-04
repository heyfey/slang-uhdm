// § genvarParamLoopVarLine125
module top(input logic [3:0] a, output logic [3:0] o);
  genvar i;

  for (
     i = 0;
     i < 4; i = i + 1) begin : g
    assign o[i] = a[i];
  end
endmodule

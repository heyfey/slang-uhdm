// § genvarParamFile125
module top(output [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i] = 1'b0;
  end
endmodule

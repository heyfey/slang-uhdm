// § genvarParamFile125
`define GENLOOP2(N) \
  for (genvar i = 0; i < N; i++) begin : g \
    assign o[i] = 1'b1; \
  end
module top(output [3:0] o);
  `GENLOOP2(4)
endmodule

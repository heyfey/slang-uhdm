// § ppOutputCol166
`define W 8
`define DECL(n) \
  logic [`W-1:0] n; \
  assign n = `W'd3;
module top(output [7:0] o);
  `DECL(x)
  assign o = x;
endmodule

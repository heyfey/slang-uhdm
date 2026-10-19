// § macroIncludeCol410
`define Q(x) `"x.svh`"
module top;
  `include `Q(inc)
  logic b;
endmodule

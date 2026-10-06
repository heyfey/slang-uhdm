// § macroStrBodyLen268
`define G(x) `"pre``-``post_``x`"
module top;
  int a, b;
  initial $display("%s %0d", `G(zz), a + b);
endmodule

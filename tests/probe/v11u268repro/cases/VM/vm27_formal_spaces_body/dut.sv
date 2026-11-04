// § macroStrBodyLen268
`define S2(x) `"x   -   x`"
module top; int a;
  initial $display("%s %0d", `S2(q), a + 1);
endmodule

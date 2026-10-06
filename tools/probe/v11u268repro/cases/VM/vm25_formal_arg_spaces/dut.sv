// § macroStrBodyLen268
`define S(x) `"x`"
module top; int a;
  initial $display("%s %0d", `S(a    b), a + 1);
endmodule

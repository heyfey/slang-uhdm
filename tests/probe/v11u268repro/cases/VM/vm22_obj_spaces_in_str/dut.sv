// § macroStrBodyLen268
`define SP `"a    b`"
module top; int a;
  initial $display("%s %0d", `SP, a + 1);
endmodule

// § macroStrBodyLenCommentAbstains268v
`define LC `"a/*x*/b`"
module top; int a;
  initial $display("%s %0d", `LC, a + 1);
endmodule

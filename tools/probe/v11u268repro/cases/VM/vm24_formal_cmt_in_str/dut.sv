// § macroStrBodyLenCommentAbstains268v
`define CM(__x) `"/*c*/__x`"
module top; int a;
  initial $display("%s %0d", `CM(plainc), a + 1);
endmodule

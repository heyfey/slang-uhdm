// § macroStrBodyLenCommentAbstains268v
`define CO `"/*c*/abc`"
module top; int a;
  initial $display("%s %0d", `CO, a + 1);
endmodule

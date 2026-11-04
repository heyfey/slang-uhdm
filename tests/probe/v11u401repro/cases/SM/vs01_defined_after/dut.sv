// § strLitMacroDefBeforeUse401v
module top;
  initial $display("`FOO is here");
`define FOO 42
  initial $display("FOO=%d", `FOO);
endmodule

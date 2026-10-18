// § strLitMacroDefBeforeUse401v
`define FOO 1
module top;
  initial $display("a `FOO b");
`undef FOO
`define FOO 22222
  initial $display("c `FOO d");
endmodule

// § strLitMacroRefSubst401
`define BAR hello
module top;
`undef BAR
  initial $display("x `BAR y");
endmodule

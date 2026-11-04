// § strLitMacroRefSubst401
`define GREET hey
`define WHO "bob"
module top;
  initial $display("`GREET !");
  initial $display("`GREET`GREET");
endmodule

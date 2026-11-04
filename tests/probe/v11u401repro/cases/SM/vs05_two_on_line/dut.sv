// § strLitMacroRefSubst401
`define A aaaaaa
`define B b
module top;
  initial begin $display("`A"); $display("`B and `A"); end
endmodule

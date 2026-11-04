// § lineMacroAfterDirectivePlus1_425 (control: no directive)
module top(output int o);
  assign o = `__LINE__;
endmodule

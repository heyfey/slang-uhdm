// § lineMacroAfterDirectivePlus1_425
module top(output int y);
`line 50 "other.sv" 0
  assign y = `__LINE__;
endmodule

// § lineMacroAfterDirectivePlus1_425
module top(output int o);
`line 7 "other.sv" 1
  initial $display("%0d", `__LINE__);
  assign o = `__LINE__;
endmodule

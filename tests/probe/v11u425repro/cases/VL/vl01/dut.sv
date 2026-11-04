// § lineMacroAfterDirectivePlus1_425
module top(output int y, output int z);
`line 100 "dut.sv" 0
  assign y = `__LINE__;

  assign z = `__LINE__;
endmodule

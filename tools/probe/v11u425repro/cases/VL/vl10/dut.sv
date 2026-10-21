// § lineMacroAfterDirectivePlus1_425
module top(output int y, output int z);
  assign y = `__LINE__;
`line 100 "dut.sv" 0
  assign z = `__LINE__ + 1;
endmodule

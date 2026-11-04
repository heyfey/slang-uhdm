// § lineMacroAfterDirectivePlus1_425
module top(output int y, output int z);
`line 10 "dut.sv" 1
  assign y = `__LINE__;
`line 20 "dut.sv" 2
  assign z = `__LINE__;
endmodule

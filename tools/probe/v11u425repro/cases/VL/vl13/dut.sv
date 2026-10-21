// § lineMacroAfterDirectivePlus1_425
`define LN `__LINE__
module top(output int y);
`line 100 "dut.sv" 0
  assign y = `LN;
endmodule

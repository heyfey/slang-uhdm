// § lineMacroAfterDirectivePlus1_425
module top(output int o);
`line 10 "dut.sv" 0
`line 30 "dut.sv" 0
  assign o = `__LINE__ + 1;
endmodule

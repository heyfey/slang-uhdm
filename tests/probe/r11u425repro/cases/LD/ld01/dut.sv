// § lineMacroAfterDirectivePlus1_425
module top(output int o, output int p);
`line 100 "dut.sv" 0
  assign o = `__LINE__;
  assign p = `__LINE__;
endmodule

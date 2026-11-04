// § lineMacroAfterDirectivePlus1_425 (control: the use is above the directive)
module top(output int o, output int p);
  assign o = `__LINE__;
`line 50 "dut.sv" 0
  assign p = `__LINE__;
endmodule

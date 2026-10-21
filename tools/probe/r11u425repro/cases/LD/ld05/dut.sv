// § lineMacroAfterDirectivePlus1_425 (control: __LINE__ inside a macro body)
`define L `__LINE__
module top(output int o);
`line 40 "dut.sv" 0
  assign o = `L;
endmodule

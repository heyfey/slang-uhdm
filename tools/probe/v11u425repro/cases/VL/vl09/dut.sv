// § lineMacroAfterDirectivePlus1_425
module top;
`line 100 "dut.sv" 0
  initial $display("%0d", `__LINE__);
endmodule

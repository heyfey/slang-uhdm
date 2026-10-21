// § lineMacroAfterDirectivePlus1_425
module top(output int y);
`line 100 "dut.sv" 0
  localparam int L = `__LINE__;
  assign y = L;
endmodule

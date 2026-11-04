// § lineMacroAfterDirectivePlus1_425
module top(output int y);
`line 100 "dut.sv" 0
  always_comb begin
    y = `__LINE__;
  end
endmodule

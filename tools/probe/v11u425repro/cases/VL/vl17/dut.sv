// § lineMacroAfterDirectivePlus1_425
module top #(parameter int P = `__LINE__) (output int y);
`line 100 "dut.sv" 0
  assign y = P + `__LINE__;
endmodule

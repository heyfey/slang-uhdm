// § lineMacroAfterDirectivePlus1_425
module top(input logic clk, input int a);
`line 100 "dut.sv" 0
  always @(posedge clk) assert (a != `__LINE__);
endmodule

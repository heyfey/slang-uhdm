// § lineMacroAfterDirectivePlus1_425
module top(output logic [31:0] o);
`line 200 "dut.sv" 0
  always_comb begin
    o = `__LINE__;
  end
endmodule

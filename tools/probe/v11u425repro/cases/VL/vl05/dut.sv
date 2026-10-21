// § lineDirectiveActive425v
module top(output int y);
`ifdef NOT_DEFINED_V11U425
`line 100 "dut.sv" 0
`endif
  assign y = `__LINE__;
endmodule

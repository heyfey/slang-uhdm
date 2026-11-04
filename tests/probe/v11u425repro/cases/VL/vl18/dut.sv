// § lineDirectiveActive425v
module top(output int y);
  /*
  `line 100 "dut.sv" 0
  */
  assign y = `__LINE__;
endmodule

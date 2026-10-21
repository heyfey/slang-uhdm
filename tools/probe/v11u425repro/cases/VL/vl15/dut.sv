// § lineDirectiveActive425v
module top(output int y, output int z);
  /* a comment that
`line 300 "dut.sv" 0
     ends here */ assign y = `__LINE__;
  assign z = `__LINE__;
endmodule

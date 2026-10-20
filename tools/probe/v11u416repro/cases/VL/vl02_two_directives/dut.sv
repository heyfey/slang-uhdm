// § lineDirectiveIgnored416
module top();
`line 100 "dut.sv" 1
  logic a;
`line 7 "dut.sv" 1
  logic b;
  assign a = b;
endmodule

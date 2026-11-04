// § lineDirectiveIgnored416
module top();
  `line 100 "dut.sv" 1
  logic a;
  assign a = 1'b1;
endmodule

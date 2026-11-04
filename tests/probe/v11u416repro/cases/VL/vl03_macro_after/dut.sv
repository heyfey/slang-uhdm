// § lineDirectiveIgnored416
`define ASGN(x) assign x = 1'b0;
module top;
`line 10 "dut.sv" 1
  logic a;
  `ASGN(a)
endmodule

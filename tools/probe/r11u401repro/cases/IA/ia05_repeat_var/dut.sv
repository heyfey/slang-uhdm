// § intraAsgEventCtrlEmptyDelay401
module top();
  reg a = 0, b = 1;
  wire clk = 0;
  int i = 2;
  initial a = repeat(i + 1) @(negedge clk) b;
endmodule

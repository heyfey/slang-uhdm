// § intraAsgEventCtrlEmptyDelay401
module top();
  reg a = 0, b = 1;
  wire clk = 0, rst = 0;
  initial a <= @(posedge clk or negedge rst) b;
endmodule

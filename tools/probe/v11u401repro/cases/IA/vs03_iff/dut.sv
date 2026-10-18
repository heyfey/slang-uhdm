// § intraAsgEventCtrlEmptyDelay401
module top;
  logic clk, en, a, b;
  initial a <= @(posedge clk iff en) b;
endmodule

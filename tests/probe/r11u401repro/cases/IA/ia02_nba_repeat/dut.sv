// § intraAsgEventCtrlEmptyDelay401
module top();
  reg a = 0, b = 1;
  wire clk = 0;
  initial begin
    a <= repeat(3) @(posedge clk) b;
  end
endmodule

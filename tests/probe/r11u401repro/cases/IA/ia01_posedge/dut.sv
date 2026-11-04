// § intraAsgEventCtrlEmptyDelay401
module top();
  reg a = 0, b = 1;
  wire clk = 0;
  initial begin
    a = @(posedge clk) b;
  end
endmodule

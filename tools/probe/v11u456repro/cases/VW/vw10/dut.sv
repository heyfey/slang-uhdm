// § ifcTaskFixupWalksWait456
interface bfm #(parameter int i = 3) (input logic clk);
  logic [7:0] m [4];
  int s;
  task run();
    foreach (m[i]) begin
      s = s + i;
    end
    s = s + i;
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

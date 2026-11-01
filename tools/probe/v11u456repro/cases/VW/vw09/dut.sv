// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  wire [7:0] i;
  logic [7:0] m [4];
  int s;
  task run();
    foreach (m[i]) begin
      s = s + i;
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

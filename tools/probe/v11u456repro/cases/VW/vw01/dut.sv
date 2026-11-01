// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] arr [4];
  logic [7:0] acc;
  task run();
    int i;
    i = 1;
    foreach (arr[i]) begin
      acc = acc + arr[i];
    end
    acc = acc + i;
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] a [2][3];
  int s;
  task run();
    foreach (a[i]) begin
      foreach (a[i][i2]) begin
        s = s + a[i][i2];
        $display("%0d %0d", i, i2);
      end
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

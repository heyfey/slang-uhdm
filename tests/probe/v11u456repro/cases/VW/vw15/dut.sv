// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] m [4];
  int s;
  task run();
    foreach (m[k]) begin
      int k2;
      k2 = k;
      begin
        int k;
        k = 5;
        s = s + k;
      end
      s = s + k2;
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

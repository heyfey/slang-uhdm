// § loopVarShadowedByTfDecl456v
interface bfm(input logic clk);
  logic [7:0] a [2][3];
  int s;
  task run();
    int j;
    foreach (a[i]) begin
      foreach (a[i][j]) begin
        s = s + a[i][j] + i;
      end
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

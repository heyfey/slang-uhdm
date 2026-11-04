// § loopVarShadowedByTfDecl456v
interface bfm(input logic clk);
  logic [7:0] arr [4];
  int acc;
  task run();
    begin : blk
      int j;
      j = 2;
      foreach (arr[j]) acc = acc + j;
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

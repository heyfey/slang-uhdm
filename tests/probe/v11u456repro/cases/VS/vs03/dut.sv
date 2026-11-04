// § loopVarShadowedByTfDecl456v
interface bfm(input logic clk);
  logic [7:0] arr [4];
  task run(output int n);
    n = 0;
    foreach (arr[n]) arr[n] = 8'(n);
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

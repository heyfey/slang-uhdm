// § loopVarShadowedByTfDecl456v
interface bfm(input logic clk);
  logic [7:0] arr [4];
  int acc;
  task run();
    int other;
    foreach (arr[i]) begin
      acc = acc + i + other;
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

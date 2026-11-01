// § loopVarShadowedByTfDecl456v
interface bfm(input logic clk);
  logic [7:0] arr [4];
  int acc;
  task run();
    int i;
    foreach (arr[i]) begin
      $display("%0d", i);
      wait (arr[i] != 0);
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u1(.clk(clk));
  bfm u2(.clk(clk));
endmodule

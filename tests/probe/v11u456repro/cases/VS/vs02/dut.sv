// § loopVarShadowedByTfDecl456v
interface bfm(input logic clk);
  logic [7:0] arr [4];
  int acc;
  function int sum(input int k);
    int s = 0;
    foreach (arr[k]) s = s + arr[k];
    return s + k;
  endfunction
  task run();
    acc = sum(1);
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule

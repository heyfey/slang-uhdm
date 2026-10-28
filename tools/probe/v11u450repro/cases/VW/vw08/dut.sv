// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk);
logic frame;
task drive();
  @(posedge clk) frame <= 1;
  for (int j = 0; j < 2; j++) #1 frame = ~frame;
endtask
endinterface
module top;
  logic clk;
  for (genvar g = 0; g < 2; g++) begin : gb
    bfm u (.clk(clk));
  end
endmodule

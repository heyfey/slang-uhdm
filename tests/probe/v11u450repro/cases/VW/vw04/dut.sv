// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk, output logic frame);
int cnt;
task drive();
  repeat (cnt) @(negedge clk);
  frame <= 1;
endtask
endinterface
module top;
  logic clk, f;
  bfm u (.clk(clk), .frame(f));
endmodule

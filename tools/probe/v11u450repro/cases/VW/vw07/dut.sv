// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk, output logic frame);
event ev;
task drive();
  logic clk;
  @(ev);
  @(posedge clk);
  frame <= 1;
endtask
endinterface
module top;
  logic clk, f;
  bfm u (.clk(clk), .frame(f));
endmodule

// § ifcTaskFixupWalksStmts450
interface bfm #(parameter int D = 2) (input logic clk, output logic frame);
logic en;
task drive();
  #(D) frame <= 1;
  #5 frame = en;
  @(posedge clk iff en);
  @(clk or en) frame = 0;
endtask
endinterface
module top;
  logic clk, f;
  bfm u (.clk(clk), .frame(f));
endmodule

// § ifcTaskFixupWalksStmts450
interface bfm #(parameter int N = 4) (input logic clk, output logic [7:0] data);
task drive();
  for (int i = 0; i < N; i++) begin
    @(posedge clk);
    data <= i;
  end
endtask
endinterface
module top;
  logic clk; logic [7:0] d;
  bfm #(.N(3)) u (.clk(clk), .data(d));
endmodule

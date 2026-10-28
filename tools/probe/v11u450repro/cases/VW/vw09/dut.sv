// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk, output logic [7:0] data);
int i;
int n;
task drive();
  for (int i = 0; i < 4; i++) begin
    @(posedge clk);
    data <= i;
  end
  repeat (2) begin
    int n;
    n = 3;
    @(posedge clk) data <= n;
  end
endtask
endinterface
module top;
  logic clk; logic [7:0] d;
  bfm u (.clk(clk), .data(d));
endmodule

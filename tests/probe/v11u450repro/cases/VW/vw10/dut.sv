// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk, output logic [7:0] data);
logic [7:0] v;
task automatic drive(input logic [7:0] v);
  @(posedge clk);
  while (v != 0) begin
    @(posedge clk) data <= v;
    v = v - 1;
  end
endtask
endinterface
module top;
  logic clk; logic [7:0] d;
  bfm u (.clk(clk), .data(d));
endmodule

// § ifcTaskFixupWalksStmts450
interface bfm (
   input  logic       clk,
   output logic       frame,
   output logic [3:0] data
);
initial begin
  frame <= 0;
  data <= 0;
end
task drive();
  @(posedge clk);
  frame <= 1;
  data <= {3'b0, clk};
endtask
endinterface
module top;
  logic clk, f;
  logic [3:0] d;
  bfm u (.clk(clk), .frame(f), .data(d));
endmodule

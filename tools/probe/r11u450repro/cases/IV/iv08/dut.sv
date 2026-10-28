// § ifcTaskFixupWalksStmts450
interface bfm (
   input  logic       clk,
   output logic       frame,
   output logic [3:0] data
);
logic [3:0] n;
task drive(int k);
  repeat (n) begin
    @(posedge clk);
  end
  for (int i = 0; i < 8; i++) begin
    @(negedge clk);
    data <= n;
  end
  while (n > 0) #1 n = n - 1;
  frame <= 0;
endtask
endinterface
module top;
  logic clk, f;
  logic [3:0] d;
  bfm u (.clk(clk), .frame(f), .data(d));
endmodule

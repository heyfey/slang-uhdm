// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk, output logic frame);
logic go;
task drive();
  logic go;
  go = 1;
  while (go) begin
    @(posedge clk);
    frame <= 1;
    go = 0;
  end
endtask
endinterface
module top;
  logic clk, f;
  bfm u (.clk(clk), .frame(f));
endmodule

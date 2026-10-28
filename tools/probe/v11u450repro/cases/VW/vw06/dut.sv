// § ifcTaskFixupWalksStmts450
interface bfm (input logic clk, output logic frame);
logic [3:0] k;
function automatic int f();
  int n = 0;
  while (k[n]) n++;
  return n;
endfunction
task t();
  forever begin
    @(posedge clk);
    frame <= k[0];
  end
endtask
endinterface
module top;
  logic clk, f0, f1;
  bfm u0 (.clk(clk), .frame(f0));
  bfm u1 (.clk(clk), .frame(f1));
endmodule

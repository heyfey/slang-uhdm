// § ifcTaskFixupWalksAllStmts454
interface ifc(input logic clk);
  logic x, y;
  task automatic t(input logic x);
    if (x) y <= 1;
  endtask
endinterface
module top(input logic clk);
  ifc i(clk);
  initial i.t(1'b1);
endmodule

// § ifcTaskFixupWalksAllStmts454
interface ifc(input logic clk);
  logic d, en;
  task automatic t();
    if (en) begin : b
      logic d;
      d = 1;
    end
    if (en) d <= 0;
  endtask
endinterface
module top(input logic clk);
  ifc i(clk);
  initial i.t();
endmodule

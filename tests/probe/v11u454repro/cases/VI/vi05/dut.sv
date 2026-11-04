// § ifcTaskFixupWalksAllStmts454
interface ifc(input logic clk);
  logic busy, done;
  task automatic t();
    forever begin
      @(posedge clk);
      if (done) break;
      busy <= 1;
    end
    do busy <= 0; while (!done);
  endtask
endinterface
module top(input logic clk);
  ifc i0(clk);
  ifc i1(clk);
  initial begin i0.t(); i1.t(); end
endmodule

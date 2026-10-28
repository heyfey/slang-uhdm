// § ifcTaskFixupWalksAllStmts454
interface ifc(input logic clk);
  logic req, gnt;
  modport m(output req, input gnt, import wt);
  task automatic wt();
    if (!gnt) req <= 1;
    unique case (gnt)
      1'b0: req <= 0;
      1'b1: ;
    endcase
  endtask
endinterface
module user(ifc.m p);
  initial p.wt();
endmodule
module top(input logic clk);
  ifc i(clk);
  user u(i);
endmodule

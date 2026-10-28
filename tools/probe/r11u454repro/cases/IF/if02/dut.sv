// § ifcTaskFixupWalksAllStmts454
interface bfm(input logic clk, output logic [7:0] a);
  logic [3:0] cnt;
  task drive(input int x);
    if (x == 0) a <= 8'h1;
    case (cnt) 4'd0: a = 8'h3; endcase
  endtask
endinterface
interface unused(output logic [7:0] q);
  task t(); if (q == 0) q = 1; endtask
endinterface
module top;
  logic clk; logic [7:0] a;
  bfm u1(.clk(clk), .a(a));
  bfm u2(.clk(clk), .a(a));
endmodule

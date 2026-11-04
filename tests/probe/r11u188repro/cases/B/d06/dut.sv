// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  a_p: assert property (@(posedge clk) a |-> ##1 !a);
  always @(posedge clk) assert (a);
endmodule
module tb;
  logic clk, a;
  chk u_c(.clk(clk), .a(a));
endmodule

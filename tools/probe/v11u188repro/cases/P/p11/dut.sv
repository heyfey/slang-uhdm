// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  assert property (@(posedge clk) a);
  assume property (@(posedge clk) !a |=> a);
  restrict property (@(posedge clk) a || !a);
endmodule
module mid(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
endmodule

// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  always @(posedge clk) begin
    a_proc: assert property (a);
  end
  a_p: assert property (@(posedge clk) a |-> ##1 !a);
endmodule
module mid(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
endmodule

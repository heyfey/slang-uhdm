// § elabCloneInstTreeUnstored144 (--elabuhdm)
module chk #(parameter int N = 2) (input logic clk, input logic [N-1:0] a);
  sequence s2(x); x ##1 x; endsequence
  for (genvar i = 0; i < N; i++) begin : G
    assert property (@(posedge clk) s2(a[i]));
  end
endmodule
module dut(input logic clk, input logic [1:0] a);
endmodule
bind dut chk #(.N(2)) c(.clk(clk), .a(a));

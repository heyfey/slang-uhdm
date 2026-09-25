// § elabCloneInstTreeUnstored144 (--elabuhdm)
module dut(input logic clk, input logic [1:0] a);
  sequence s_hi(x); x ##1 x; endsequence
  for (genvar i = 0; i < 2; i++) begin : G
    assert property (@(posedge clk) s_hi(a[i]));
  end
endmodule

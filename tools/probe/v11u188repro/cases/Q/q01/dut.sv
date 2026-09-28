// § bindDisplayTargetParent188
module dut(input logic clk, input logic a);
endmodule
module mon(input logic clk, input logic a);
  logic x;
  assign x = a;
endmodule
bind dut mon u_mon(.clk(clk), .a(a));
module tb;
  logic clk, a;
  for (genvar i = 0; i < 2; i++) begin : g
    dut u_dut(.clk(clk), .a(a));
  end
endmodule

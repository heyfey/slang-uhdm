// § bindDisplayTargetParent188
module dut(input logic clk, input logic a, input logic en);
endmodule
module mon(input logic clk, input logic a);
  logic x;
  assign x = a;
endmodule
bind dut mon u_mon(.clk(clk), .a(a & en));
module l2(input logic clk, input logic a, input logic en);
  dut u_dut(.clk(clk), .a(a), .en(en));
endmodule
module l1(input logic clk, input logic a, input logic en);
  l2 u_l2(.clk(clk), .a(a), .en(en));
endmodule
module tb;
  logic clk, a, en;
  l1 u_l1(.clk(clk), .a(a), .en(en));
endmodule

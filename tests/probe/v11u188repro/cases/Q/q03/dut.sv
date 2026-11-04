// § bindDisplayTargetParent188
module dut(input logic clk, input logic a);
endmodule
module mon(input logic clk, input logic a);
  logic x;
  assign x = a;
endmodule
bind dut mon u_mon(.*);
module mid(input logic clk, input logic a);
  dut u_dut(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_mid(.clk(clk), .a(a));
endmodule

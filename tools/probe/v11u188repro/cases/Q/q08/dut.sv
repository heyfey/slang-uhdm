// § bindDisplayTargetParent188
module dut(input logic clk, input logic a);
endmodule
module mon(input logic clk, input logic a);
  logic x;
  assign x = a;
endmodule
module mid(input logic clk, input logic a);
  dut u_dut(.clk(clk), .a(a));
endmodule
bind dut: tb.u_mid.u_dut mon u_mon(.clk(clk), .a(a));
module tb;
  logic clk, a;
  mid u_mid(.clk(clk), .a(a));
endmodule

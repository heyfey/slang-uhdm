// § bindDisplayTargetParent188
module dut(input logic clk, input logic a);
  logic int_sig;
  assign int_sig = !a;
endmodule
module mon(input logic clk, input logic a, input logic b);
  logic x;
  assign x = a ^ b;
endmodule
bind dut mon u_mon(.clk(clk), .a(a), .b(int_sig));
module mid(input logic clk, input logic a);
  dut u_dut(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_mid(.clk(clk), .a(a));
endmodule

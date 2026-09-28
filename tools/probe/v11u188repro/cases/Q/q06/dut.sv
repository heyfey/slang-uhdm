// § bindDisplayTargetParent188
interface ifc(input logic clk);
  logic a;
endinterface
module mon(input logic clk, input logic a);
  logic x;
  assign x = a;
endmodule
bind ifc mon u_mon(.clk(clk), .a(a));
module mid(input logic clk);
  ifc u_if(.clk(clk));
endmodule
module tb;
  logic clk;
  mid u_mid(.clk(clk));
endmodule

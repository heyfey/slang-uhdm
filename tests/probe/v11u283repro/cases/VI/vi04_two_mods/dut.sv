// § ifaceInstFirstProcsShared283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
module m1 (input logic clk, output logic [3:0] o); ifc a (.clk(clk)); assign o = a.d; endmodule
module m2 (input logic clk, output logic [3:0] o); ifc b (.clk(clk)); assign o = b.d; endmodule
module dut (input logic clk, output logic [3:0] o1, o2);
  m1 u1 (.clk(clk), .o(o1));
  m2 u2 (.clk(clk), .o(o2));
endmodule

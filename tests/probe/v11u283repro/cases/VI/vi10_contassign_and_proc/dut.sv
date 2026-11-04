// § ifaceInstFirstProcsShared283
interface ifc (input logic clk, input logic [3:0] din);
  logic [3:0] d, e;
  assign e = din ^ 4'h1;
  always_ff @(posedge clk) d <= e;
endinterface
module dut (input logic clk, input logic [3:0] x, y, output logic [3:0] o1, o2);
  ifc a (.clk(clk), .din(x)); ifc b (.clk(clk), .din(y));
  assign o1 = a.d; assign o2 = b.d;
endmodule

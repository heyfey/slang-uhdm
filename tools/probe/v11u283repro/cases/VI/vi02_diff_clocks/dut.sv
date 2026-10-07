// § ifaceInstFirstProcsShared283
interface ifc (input logic clk);
  logic [3:0] d;
  always_ff @(posedge clk) d <= d + 1;
endinterface
module dut (input logic c1, c2, output logic [3:0] o1, o2);
  ifc a (.clk(c1));
  ifc b (.clk(c2));
  assign o1 = a.d; assign o2 = b.d;
endmodule

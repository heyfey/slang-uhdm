// § ifaceInstFirstProcsShared283
interface ifc #(parameter int W = 2) (input logic clk);
  logic [7:0] d;
  always @(posedge clk) d <= d + W;
endinterface
module dut (input logic clk, output logic [7:0] o1, o2);
  ifc #(.W(1)) a (.clk(clk));
  ifc #(.W(3)) b (.clk(clk));
  assign o1 = a.d; assign o2 = b.d;
endmodule

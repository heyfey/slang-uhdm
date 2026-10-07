// § ifaceInstFirstProcsShared283
interface inner (input logic clk);
  logic [3:0] q;
  always @(posedge clk) q <= q + 1;
endinterface
interface outer (input logic clk);
  inner n (.clk(clk));
endinterface
module dut (input logic clk, output logic [3:0] o1, o2);
  outer a (.clk(clk)); outer b (.clk(clk));
  assign o1 = a.n.q; assign o2 = b.n.q;
endmodule

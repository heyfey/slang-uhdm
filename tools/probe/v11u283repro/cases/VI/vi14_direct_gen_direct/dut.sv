// § progLastInstSrcOrder283v
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
module dut (input logic clk, output logic [3:0] o1, o2, o3);
  ifc a (.clk(clk));
  if (1) begin : g
    ifc b (.clk(clk));
  end
  ifc c (.clk(clk));
  assign o1 = a.d; assign o2 = g.b.d; assign o3 = c.d;
endmodule

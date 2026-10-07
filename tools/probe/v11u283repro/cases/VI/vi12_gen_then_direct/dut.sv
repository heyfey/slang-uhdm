// § progLastInstSrcOrder283v
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
module dut (input logic clk, output logic [3:0] o1, o2);
  if (1) begin : g
    ifc a (.clk(clk));
  end
  ifc b (.clk(clk));
  assign o1 = g.a.d; assign o2 = b.d;
endmodule

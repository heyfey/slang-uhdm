// § ifaceInstFirstProcsShared283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) begin : blk
    logic [3:0] t;
    t = d + 1;
    d <= t;
  end
endinterface
module dut (input logic clk, output logic [3:0] o1, o2);
  ifc a (.clk(clk)); ifc b (.clk(clk));
  assign o1 = a.d; assign o2 = b.d;
endmodule

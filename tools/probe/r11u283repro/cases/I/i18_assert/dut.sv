// § ifaceInstFirstProcsShared283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) begin
    d <= d + 1;
  end
  initial begin
    d = 0;
  end
endinterface
module dut (input logic clk, output logic [31:0] o);
  ifc a (.clk(clk)); ifc b (.clk(clk)); ifc c (.clk(clk)); ifc e (.clk(clk));
  assign o = 32'd0;
endmodule

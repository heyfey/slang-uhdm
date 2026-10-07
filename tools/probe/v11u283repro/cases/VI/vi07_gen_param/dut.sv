// § ifaceInstFirstProcsShared283
interface ifc #(parameter int W = 1) (input logic clk);
  logic [7:0] d;
  always_comb d = W;
endinterface
module dut (input logic clk, output logic [7:0] o0, o1);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc #(.W(i + 1)) u (.clk(clk));
  end
  assign o0 = g[0].u.d; assign o1 = g[1].u.d;
endmodule

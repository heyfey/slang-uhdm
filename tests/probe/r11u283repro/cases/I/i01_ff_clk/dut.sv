// § ifaceInstFirstProcsShared283
interface ifc (input logic clk);
  logic [3:0] q;
  always_ff @(posedge clk) q <= q + 1;
endinterface
module dut (input logic clk, output logic [3:0] o);
  ifc a (.clk(clk));
  ifc b (.clk(clk));
  assign o = a.q ^ b.q;
endmodule

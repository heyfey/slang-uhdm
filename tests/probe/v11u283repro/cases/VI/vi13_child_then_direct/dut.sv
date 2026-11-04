// § progLastInstSrcOrder283v
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
module sub (input logic clk, output logic [3:0] o); ifc s (.clk(clk)); assign o = s.d; endmodule
module dut (input logic clk, output logic [3:0] o1, o2);
  sub u (.clk(clk), .o(o1));
  ifc b (.clk(clk));
  assign o2 = b.d;
endmodule

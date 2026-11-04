// § ifacePortViewNoProcs283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
module sub (ifc m, output logic [3:0] o); assign o = m.d; endmodule
module dut (input logic clk, output logic [3:0] o);
  ifc a (.clk(clk));
  sub s (.m(a), .o(o));
endmodule

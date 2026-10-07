// § ifacePortViewNoProcs283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
module sub (interface m, output logic [3:0] o); assign o = m.d; endmodule
module dut (input logic clk, output logic [3:0] o1, o2);
  ifc a (.clk(clk)); ifc b (.clk(clk));
  sub s1 (.m(a), .o(o1));
  sub s2 (.m(b), .o(o2));
endmodule

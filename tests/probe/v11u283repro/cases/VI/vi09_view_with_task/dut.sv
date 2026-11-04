// § ifacePortViewNoProcs283
interface ifc (input logic clk);
  logic [3:0] d;
  task automatic bump(); d <= d + 1; endtask
  initial d = 0;
  always @(posedge clk) bump();
  modport mp (input d, import bump);
endinterface
module sub (ifc.mp m, output logic [3:0] o); assign o = m.d; endmodule
module dut (input logic clk, output logic [3:0] o1, o2);
  ifc a (.clk(clk)); ifc b (.clk(clk));
  sub s1 (.m(a), .o(o1));
  sub s2 (.m(b), .o(o2));
endmodule

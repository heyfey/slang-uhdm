// § ifPortViewTdAliasDefName419
package p;
  typedef logic [3:0] f_t;
endpackage
interface i #(parameter p::f_t A = 5) (input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i #(.A(3)) u(clk);
  dut d(u);
endmodule

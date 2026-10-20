// § ifPortViewTdAliasDefName419
package p;
  typedef logic [3:0] f_t;
  parameter f_t A = 5;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i u(clk);
  i w(clk);
  dut d(u);
  dut e(w);
endmodule

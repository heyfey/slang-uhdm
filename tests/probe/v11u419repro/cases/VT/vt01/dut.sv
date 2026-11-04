// § ifPortViewTdAliasDefName419
package p;
  typedef int unsigned f_t;
  parameter f_t A = 5;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module dut2(i.port y);
endmodule
module top;
  logic clk;
  i u(clk);
  dut d(u);
  dut2 e(u);
endmodule

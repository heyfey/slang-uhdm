// § ifPortViewTdAliasDefName419
package p;
  typedef int unsigned f_t;
  parameter f_t A = 5;
  parameter f_t B = A + 1;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
  f_t v = A;
endmodule
module top;
  logic clk;
  i u(clk);
  dut d(u);
endmodule

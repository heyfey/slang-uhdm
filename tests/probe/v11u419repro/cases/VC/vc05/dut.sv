// § ifPortViewPaLhsOwn419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
  modport port(input clk, d);
  modport oth(input clk, output d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i u[2](clk);
  dut d(u[1]);
endmodule

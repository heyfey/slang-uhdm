// § ifPortViewPaLhsOwn419
package p;
  typedef bit [7:0] f_t;
  parameter f_t A = 8'h05;
  parameter f_t B = A | 8'h10;
  parameter W = 120;
  parameter S = W*8-1;
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
  dut d(u);
endmodule

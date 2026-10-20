// § ifPortViewPaLhsOwn419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x, output [7:0] q);
  assign q = x.d;
endmodule
module top(input clk, output [7:0] o);
  i u(clk);
  dut d(u, o);
endmodule

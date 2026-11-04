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
  assign q = x.d + S[7:0];
endmodule
module top(input clk, output [7:0] o1, o2);
  i u(clk);
  i v(clk);
  dut d(u, o1);
  dut e(v, o2);
endmodule

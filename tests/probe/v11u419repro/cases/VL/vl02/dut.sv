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
module sub(i.port z);
endmodule
module dut(i.port x);
  sub s(x);
endmodule
module top;
  logic clk;
  i u(clk);
  dut d(u);
endmodule

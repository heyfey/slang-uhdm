// § ifPortViewPaLhsOwn419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
package q;
  parameter K = 7;
endpackage
import p::*;
import q::*;
interface i #(parameter N = 2) (input clk);
  logic [N-1:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i #(.N(3)) u(clk);
  dut d(u);
endmodule

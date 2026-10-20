// § ifPortViewArithIntForm419
package p;
  parameter W = 120;
  parameter N = 200;
  parameter S = W*8-1;
  parameter L = W*N*8-1;
endpackage
import p::*;
interface ii(input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
interface oi(input clk);
  logic [7:0] d;
  modport port(input clk, output d);
endinterface
module dut(ii.port a, oi.port b);
  always @(posedge a.clk) b.d <= a.d;
endmodule
module top;
  logic clk;
  ii u(clk);
  oi v(clk);
  dut d(u, v);
endmodule

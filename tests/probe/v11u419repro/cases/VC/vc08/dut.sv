// § ifPortViewArithIntForm419
package p;
  parameter W = 120;
  parameter S = W*8-1;
  parameter int unsigned U = 7*3;
  parameter bit [7:0] B = 3*5;
  parameter logic [40:0] L = 41'd3 * 2;
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
  i u(clk);
  dut d(u);
endmodule

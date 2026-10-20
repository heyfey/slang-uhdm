// § ifPortViewArithIntForm419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
import p::*;
interface i #(parameter N = 2) (input clk);
  logic [N-1:0] d;
  localparam M = N*4-1;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i #(.N(5)) u(clk);
  dut d(u);
endmodule

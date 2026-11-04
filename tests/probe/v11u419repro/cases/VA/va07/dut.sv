// § ifPortViewArithIntForm419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
endinterface
module dut(i x, output logic [S:0] o);
  assign o = '0;
endmodule
module top;
  logic clk;
  logic [S:0] o;
  i u(clk);
  dut d(u, o);
endmodule

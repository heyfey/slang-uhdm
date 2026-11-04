// § ifPortViewArithIntForm419
package p;
  parameter int unsigned W = 120;
  parameter int unsigned S = W*8-1;
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

// § ifPortViewArithIntForm419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
interface i(input clk);
  import p::*;
  logic [S:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i u(clk);
  dut d(u);
endmodule

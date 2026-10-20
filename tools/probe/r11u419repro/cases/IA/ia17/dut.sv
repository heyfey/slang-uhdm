// § ifPortViewPaLhsOwn419
package p;
  parameter W = 120;
  parameter S = W*8-1;
endpackage
package q;
  import p::*;
  export p::*;
  parameter R = W-2;
endpackage
import p::*;
import q::*;
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

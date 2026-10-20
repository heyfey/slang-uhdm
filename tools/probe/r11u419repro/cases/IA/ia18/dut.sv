// § ifPortViewTdAliasDefName419
package p;
  typedef logic [3:0] n_t;
  typedef bit [7:0] f_t;
  parameter n_t A = 4'd3;
  parameter f_t B = 8'h10;
  parameter f_t C = B + 1;
endpackage
import p::*;
interface i(input clk);
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i x);
endmodule
module top;
  logic clk;
  i u(clk);
  dut d(.x(u));
endmodule

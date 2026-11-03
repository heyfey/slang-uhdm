// § unitImpRootFileDef477
package p;
  parameter int W = 4;
endpackage
import p::*;
`include "./a_if.sv"
`include "./adder.sv"
module top;
  logic clk;
  logic rst;
  a_if in(clk, rst);
  a_if out(clk, rst);
  adder sum(in, out);
endmodule

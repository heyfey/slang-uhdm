// § clsScopedOvRhsRefObj483
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
interface ifc #(A = 8) (input logic clk, output logic [A-1:0] x);
  logic [A-1:0] d;
endinterface
module top;
  import p::*;
  logic clk;
  logic [15:0] x;
  ifc #(.A(S::w)) u(.clk(clk), .x(x));
endmodule

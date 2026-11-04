// § implicitPortPaLastIface419
interface ifc #(R = 100) (input clk);
  import pkq::*;
  logic [R-1:0] x;
endinterface
package pkq;
  parameter Q = 9;
endpackage
module top;
  logic clk;
  ifc u(clk);
endmodule

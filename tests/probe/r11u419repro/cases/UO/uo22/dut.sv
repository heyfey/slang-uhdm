// § implicitPortPaLastIface419
package pk;
  parameter Q = 9;
endpackage
interface ifc import pk::*; #(parameter A = 4, int B = 2) ();
  logic [A-1:0] x;
  localparam L = A * Q;
endinterface
module top;
  ifc u();
endmodule

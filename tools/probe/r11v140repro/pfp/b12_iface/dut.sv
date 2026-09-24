// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter int X = 9;
endpackage
interface ifc import p::*; #(parameter int P = X);
  logic [P-1:0] d;
endinterface
module top; ifc i(); endmodule

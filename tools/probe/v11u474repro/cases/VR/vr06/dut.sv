// § clsScopedRangeKept474 (attack: interface net, instantiated)
package p; class S; localparam w = 8; endclass endpackage
interface ifc; import p::*;
  logic [S::w-1:0] d;
endinterface
module top; ifc i(); endmodule

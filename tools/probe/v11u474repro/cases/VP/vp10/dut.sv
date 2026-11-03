// § elabParamClsScopedSubst474 (attack: interface inside the overridden module, module nets after it)
package p; class S; localparam w = 16; endclass endpackage
interface ifc #(A = 8) ();
  logic [A-1:0] d;
endinterface
module sub #(A = 8) ();
  ifc #(.A(A)) i();
  logic [A-1:0] after;
endmodule
module top; import p::*; sub #(.A(S::w)) u(); ifc #(.A(4)) j(); endmodule

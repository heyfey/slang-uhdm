// § elabParamClsScopedSubst474 (attack: override through a class typedef alias)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top; import p::*; typedef S St; sub #(.A(St::w)) u(); endmodule

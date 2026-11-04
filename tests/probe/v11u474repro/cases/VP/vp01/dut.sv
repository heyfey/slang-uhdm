// § elabParamClsScopedSubst474 (attack: several bound shapes)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8) ();
  logic [A:0] d0;
  logic [2*A-1:0] d1;
  logic [A-1:A/2] d2;
endmodule
module top; import p::*; sub #(.A(S::w)) u(); endmodule

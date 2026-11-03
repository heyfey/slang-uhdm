// § elabParamClsScopedSubst474 (attack: two parameters, one class-scoped)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8, B = 2) ();
  logic [A+B-1:0] d;
  logic [B-1:0] e;
endmodule
module top; import p::*; sub #(.A(S::w), .B(3)) u(); endmodule

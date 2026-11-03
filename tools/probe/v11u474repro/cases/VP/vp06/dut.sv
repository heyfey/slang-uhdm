// § elabParamClsScopedSubst474 (attack: bound through a body localparam)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8) ();
  localparam L = A;
  logic [L-1:0] d;
endmodule
module top; import p::*; sub #(.A(S::w)) u(); endmodule

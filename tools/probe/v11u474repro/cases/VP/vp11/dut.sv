// § elabParamClsScopedSubst474 (attack: net declaration assignment)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8) ();
  wire [A-1:0] n = '0;
endmodule
module top; import p::*; sub #(.A(S::w)) u(); endmodule

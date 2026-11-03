// § elabParamClsScopedSubst474 (attack: pass-through to a nested instance)
package p; class S; localparam w = 16; endclass endpackage
module leaf #(B = 1) ();
  logic [B-1:0] q;
endmodule
module mid #(A = 8) ();
  logic [A-1:0] d;
  leaf #(.B(A)) l();
endmodule
module top; import p::*; mid #(.A(S::w)) m(); endmodule

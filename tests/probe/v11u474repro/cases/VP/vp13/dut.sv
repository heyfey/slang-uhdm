// § elabParamClsScopedSubst474 (attack: typed ranged parameter)
package p; class S; localparam w = 16; endclass endpackage
module sub #(logic [7:0] A = 8) ();
  logic [A-1:0] d;
endmodule
module top; import p::*; sub #(.A(S::w)) u(); endmodule

// § elabParamClsScopedSubst474 (attack: two instances, one literal override)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top; import p::*; sub #(.A(S::w)) u(); sub #(.A(4)) v(); sub w(); endmodule

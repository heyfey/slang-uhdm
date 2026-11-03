// § clsScopedRangeKept474 (attack: class enum constant as bound)
package p; class S; typedef enum {A, B, C} e_t; endclass endpackage
module top; import p::*;
  wire [S::C:0] a;
endmodule

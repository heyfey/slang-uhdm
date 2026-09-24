// § impLhsCloneFlippedDefView124
package p; typedef enum logic [1:0] {A, B, C} e_t; parameter e_t X = B; endpackage
module m import p::*; #(parameter e_t Q = X) (); endmodule
module top; m u(); endmodule

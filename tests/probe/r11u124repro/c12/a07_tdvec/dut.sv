// § impLhsCloneFlippedDefView124
package p; typedef logic [7:0] v_t; parameter v_t X = 8'h3; endpackage
module m import p::*; #(parameter v_t Q = X) (); endmodule
module top; m u(); endmodule

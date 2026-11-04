// § impLhsCloneFlippedDefView124
package p; parameter X = 4; endpackage
module m import p::*; #(parameter Q = X) (); endmodule
module top; m u(); endmodule

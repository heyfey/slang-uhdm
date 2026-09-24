// § impLhsCloneFlippedDefView124
package p; parameter string X = "ab"; endpackage
module m import p::*; #(parameter string Q = X) (); endmodule
module top; m u(); endmodule

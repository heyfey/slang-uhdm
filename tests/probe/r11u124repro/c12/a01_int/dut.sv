// § impLhsCloneFlippedDefView124
package p; parameter int X = 4; endpackage
module m import p::*; #(parameter int Q = X) (); endmodule
module top; m u(); endmodule

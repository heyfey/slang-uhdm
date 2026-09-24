// § impLhsCloneFlippedDefView124
package p; parameter logic [7:0] X = 8'h5; endpackage
module m import p::*; #(parameter logic [7:0] Q = X) (); endmodule
module top; m u(); endmodule

// § impLhsCloneFlippedDefView124
package p; parameter bit [1:0][3:0] X = 8'h12; endpackage
module m import p::*; #(parameter bit [1:0][3:0] Q = X) (); endmodule
module top; m u(); endmodule

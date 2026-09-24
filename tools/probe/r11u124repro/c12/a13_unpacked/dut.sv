// § impLhsCloneFlippedDefView124
package p; parameter logic [3:0] X [2] = '{4'h1, 4'h2}; endpackage
module m import p::*; (); logic [3:0] y = X[0]; endmodule
module top; m u(); endmodule

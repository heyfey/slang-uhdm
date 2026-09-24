// § impLhsCloneFlippedDefView124
package p; typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t; parameter s_t X = '{a:1, b:2}; endpackage
module m import p::*; #(parameter s_t Q = X) (); endmodule
module top; m u(); endmodule

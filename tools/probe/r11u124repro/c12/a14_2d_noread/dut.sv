// § impLhsCloneFile124
package p; parameter logic [7:0][3:0] X = 32'habcd; endpackage
module m import p::*; (); endmodule
module top; m u(); endmodule

// § impLhsCloneFile124
package p; parameter logic [7:0][3:0] X = 32'habcd; endpackage
module m; import p::X; localparam logic [7:0][3:0] Q = X; endmodule
module top; m u(); endmodule

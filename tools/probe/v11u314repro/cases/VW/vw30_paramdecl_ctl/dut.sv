// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; localparam logic [7:0] W0 = 8'hA5; localparam logic [1:0] X = W0[3 +: p::N]; logic [1:0] o; assign o = X; endmodule

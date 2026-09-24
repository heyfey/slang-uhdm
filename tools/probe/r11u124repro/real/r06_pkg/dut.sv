// § realLitValueIsText124
package p; parameter real R = 3.25; localparam real S = 0.125; endpackage
module top(output real o); import p::*; assign o = R + S; endmodule

// § realLitValueIsText124
package p; localparam real S = 0.125; endpackage
module top(output real o); parameter real R = p::S; assign o = R; endmodule

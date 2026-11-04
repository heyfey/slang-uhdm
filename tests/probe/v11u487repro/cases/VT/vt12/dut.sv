// § caFoldTsFollowsPa487
package p; localparam P = 6; endpackage
module m (output logic [7:0] o); import p::*; localparam B = P + 1; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule

// § caFoldValueFollowsPa487
package p; localparam P = 'hF3; endpackage
module m (output logic [3:0] o); localparam B = p::P; assign o = B; endmodule
module top; logic [3:0] o; m u(o); endmodule

// § unboundedSubSize64_491
package pk; localparam A = 4'd3; localparam B = A - 4'd1; endpackage
module top; import pk::*; logic [7:0] o; assign o = B + 1; endmodule

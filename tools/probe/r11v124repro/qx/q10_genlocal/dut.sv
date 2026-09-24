// § pkgQualFoldSpanByView124
package pk; parameter int X = 5; endpackage
module top(output int o); if (1) begin : g localparam int L = pk::X; assign o = L; end endmodule

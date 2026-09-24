// § pkgQualFoldSpanByView124
package pk; parameter int X = 5; endpackage
module top import pk::*; #(parameter int Q = 1) (output int o); localparam int L = pk::X; assign o = L + Q; endmodule

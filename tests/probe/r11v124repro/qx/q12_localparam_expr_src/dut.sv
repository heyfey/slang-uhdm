// § pkgQualFoldSpanByView124
package pk; localparam int A = 3; localparam int X = A * 4 + 1; endpackage
module m (output int o); localparam int L = pk::X; assign o = L; endmodule
module top(output int o); m u(.o(o)); endmodule

// § pkgFoldLeftParenSpan158
package pkg; parameter int A = 8; parameter logic [7:0] C = (A + 1) << 1; endpackage
module dut (output int o); import pkg::*; assign o = C; endmodule

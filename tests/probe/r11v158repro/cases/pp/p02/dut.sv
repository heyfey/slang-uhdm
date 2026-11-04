// § pkgFoldLeftParenSpan158
package pkg; parameter int A = 8; parameter int C = ($clog2(A)) * 2; parameter int D = (A - 1) - (A - 2); endpackage
module dut (output int o, output int q); assign o = pkg::C; assign q = pkg::D; endmodule

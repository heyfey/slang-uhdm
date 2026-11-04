// § pkgFoldLeftParenSpan158
package pkg; localparam int A = 8; localparam int C = (A + 1) % 3; endpackage
module dut (output int o); assign o = pkg::C; endmodule

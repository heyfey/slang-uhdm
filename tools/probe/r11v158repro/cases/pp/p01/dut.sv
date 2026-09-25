// § pkgFoldLeftParenSpan158
package pkg; parameter int A = 5; parameter int B = 2; parameter int C = (A) + B; endpackage
module dut (output int o); assign o = pkg::C; endmodule

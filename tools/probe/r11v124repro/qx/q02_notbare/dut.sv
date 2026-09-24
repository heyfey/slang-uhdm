// § pkgQualFoldSpanByView124
package pk; parameter int X = 5; endpackage
module top #(parameter int P = pk::X + 1) (output int o); assign o = P; endmodule

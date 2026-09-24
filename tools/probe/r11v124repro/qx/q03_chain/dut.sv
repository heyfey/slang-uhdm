// § pkgQualFoldSpanByView124
package a; parameter int X = 1; endpackage
package b; parameter int Y = a::X; endpackage
module top #(parameter int Z = b::Y) (output int o); assign o = Z; endmodule

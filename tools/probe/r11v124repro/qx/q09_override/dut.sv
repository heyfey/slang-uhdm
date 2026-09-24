// § pkgQualFoldSpanByView124
package pk; parameter int X = 5; parameter int Y = 9; endpackage
module m #(parameter int P = pk::X) (output int o); assign o = P; endmodule
module top(output int o); m #(.P(pk::Y)) u(.o(o)); endmodule

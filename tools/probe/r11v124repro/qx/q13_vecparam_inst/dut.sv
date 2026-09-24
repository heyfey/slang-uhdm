// § pkgQualFoldSpanByView124
package pk; localparam logic [3:0] X = 4'hA; endpackage
module m #(parameter logic [3:0] P = pk::X) (output logic [3:0] o); assign o = P; endmodule
module top(output logic [3:0] o); m u(.o(o)); endmodule

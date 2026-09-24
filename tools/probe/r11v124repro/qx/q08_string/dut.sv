// § pkgQualFoldSpanByView124
package pk; parameter string S = "hi"; endpackage
module top #(parameter string P = pk::S) (output logic [7:0] o); assign o = P[0]; endmodule

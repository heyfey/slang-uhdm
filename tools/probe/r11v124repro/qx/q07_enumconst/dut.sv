// § pkgQualFoldSpanByView124
package pk; typedef enum logic [1:0] {RA, RB} e_t; endpackage
module top #(parameter pk::e_t P = pk::RB) (output logic [1:0] o); assign o = P; endmodule

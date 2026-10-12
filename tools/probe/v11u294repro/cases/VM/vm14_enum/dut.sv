// § castModTypeParamDefaultTs294
// a type parameter defaulting to a package enum
package pk; typedef enum logic [1:0] {A, B, C} e_t; endpackage
module top #(parameter type T = pk::e_t) (input logic [1:0] a, output logic [1:0] y);
  always_comb y = T'(a);
endmodule

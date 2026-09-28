// § tpArrayElemBindsDefDefault206
package pk; typedef enum logic [1:0] {A, B, C} e_t; endpackage
module b05 #(parameter type t = pk::e_t) (input t i, output t o);
  t m [3];
  assign m[0] = i;
  assign o = m[0];
endmodule

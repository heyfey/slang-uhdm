// § tpUseSigBindsTpObj291
package pk; typedef enum logic [1:0] {A, B, C} e_t; endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = (a == pk::B);
endmodule
module dut (input pk::e_t a, output logic o);
  child #(.T(pk::e_t)) u (.a(a), .o(o));
endmodule

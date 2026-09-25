// § enumQualDefaultDefSpan147 § tpOvrTypedefStructSpan152
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module child #(parameter type T = logic, parameter pk::e_t E = pk::B)(input T d_i, output logic [1:0] o);
  assign o = E ^ {1'b0, ^d_i};
endmodule
module tb;
  typedef struct packed { logic [3:0] x; pk::e_t k; } my_t;
  my_t d;
  logic [1:0] o;
  child #(.T(my_t)) c(.d_i(d), .o(o));
endmodule

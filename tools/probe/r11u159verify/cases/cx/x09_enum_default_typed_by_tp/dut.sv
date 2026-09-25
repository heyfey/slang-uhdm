// § enumQualDefaultDefSpan147 § tpOvrTypedefStructSpan152
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module child #(parameter type T = pk::e_t, parameter T E = pk::C)(output logic [1:0] o);
  assign o = E;
endmodule
module tb;
  typedef struct packed { logic [1:0] x; } my_t;
  logic [1:0] o1, o2;
  child #(.T(my_t), .E(2'd1)) c1(.o(o1));
  child c2(.o(o2));
endmodule

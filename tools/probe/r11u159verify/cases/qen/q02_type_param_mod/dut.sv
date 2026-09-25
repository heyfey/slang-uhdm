// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module child #(parameter type T = pk::e_t, parameter T P = pk::B)(output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o);
  child u(.o(o));
endmodule

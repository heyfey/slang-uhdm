// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module child #(parameter pk::e_t P = pk::C)(output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o1, o2);
  child u1(.o(o1));
  child u2(.o(o2));
endmodule

// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module sub #(parameter P = pk::B)(output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o);
  sub u(o);
endmodule

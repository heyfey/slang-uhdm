// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top(output logic [1:0] o);
  parameter pk::e_t P = pk::B;
  assign o = P;
endmodule

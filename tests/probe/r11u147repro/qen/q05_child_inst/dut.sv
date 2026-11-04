// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module sub #(parameter pk::e_t P = pk::A) (output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o);
  sub #(.P(pk::C)) u(.o(o));
endmodule

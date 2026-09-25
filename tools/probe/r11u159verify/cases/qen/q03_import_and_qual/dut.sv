// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [2:0] {A = 3'd1, B = 3'd4} e_t;
endpackage
module top import pk::*; #(parameter e_t P = pk::B)(output logic [2:0] o);
  assign o = P;
endmodule

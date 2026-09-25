// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top(output logic [1:0] o);
  parameter int P = pk::C;
  localparam logic [1:0] L = pk::B;
  assign o = P[1:0] ^ L;
endmodule

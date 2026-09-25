// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
interface ifc;
  parameter pk::e_t P = pk::C;
  logic [1:0] q;
  assign q = P;
endinterface
module top(output logic [1:0] o);
  ifc u();
  assign o = u.q;
endmodule

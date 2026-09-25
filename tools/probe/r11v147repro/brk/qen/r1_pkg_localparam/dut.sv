// § enumQualDefaultDefSpan147
package pa;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package pb;
  localparam pa::e_t X = pa::B;
endpackage
module top(output logic [1:0] o);
  assign o = pb::X;
endmodule

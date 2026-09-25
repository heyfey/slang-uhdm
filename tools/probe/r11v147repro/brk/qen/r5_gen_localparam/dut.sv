// § enumQualDefaultDefSpan147
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top(output logic [1:0] o);
  if (1) begin : g
    localparam pk::e_t L = pk::C;
    assign o = L;
  end
endmodule

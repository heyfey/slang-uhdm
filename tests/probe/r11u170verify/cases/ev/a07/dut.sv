// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [2:0] { ONE, TWO, SIX = 6 } enum_t; typedef enum_t alias_t; typedef enum_t alias2_t; endpackage
module dut (output logic [2:0] o);
  pkg::alias_t b;
  pkg::alias2_t c [2];
  always_comb begin b = pkg::ONE; c[0] = b; c[1] = pkg::SIX; end
  assign o = c[1];
endmodule

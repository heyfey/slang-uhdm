// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [3:0] { ONE, TWO, SIX = 6 } enum_t; typedef enum_t alias_t; endpackage
module dut (output logic [3:0] o);
  pkg::alias_t b, c;
  assign b = pkg::SIX;
  assign c = b;
  assign o = c;
endmodule

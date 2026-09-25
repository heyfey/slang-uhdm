// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [7:0] {ONE, TWO} enum_t; typedef enum_t alias_t; endpackage
module dut(output pkg::alias_t o); pkg::alias_t c = pkg::ONE; endmodule

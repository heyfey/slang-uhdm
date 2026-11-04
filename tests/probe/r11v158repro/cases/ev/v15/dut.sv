// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [7:0] {ONE, TWO} enum_t; typedef enum_t alias_t; endpackage
module sub; pkg::alias_t c [2]; endmodule
module dut; pkg::alias_t b; sub u(); endmodule

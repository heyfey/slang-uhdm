// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [7:0] {ONE, TWO} enum_t; typedef enum_t alias_t; typedef alias_t alias2_t; endpackage
module dut; pkg::alias2_t b; endmodule

// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [7:0] {ONE, TWO} enum_t; typedef enum_t alias_t; endpackage
module dut; pkg::alias_t b; if (1) begin : g pkg::alias_t c [2]; end endmodule

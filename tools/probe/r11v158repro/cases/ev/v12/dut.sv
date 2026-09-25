// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [7:0] {ONE, TWO} enum_t; typedef enum_t alias_t; endpackage
module dut(input logic clk); pkg::alias_t b; always_ff @(posedge clk) b <= pkg::TWO; endmodule

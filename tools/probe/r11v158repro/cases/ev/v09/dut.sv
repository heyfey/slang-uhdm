// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [7:0] {ONE, TWO} enum_t; typedef enum_t alias_t; endpackage
module t1; pkg::alias_t c [2]; endmodule
module t2; pkg::alias_t b; endmodule

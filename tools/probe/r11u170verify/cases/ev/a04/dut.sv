// § enumAliasEndAtDimOrInitDecl158
package pkg;
  typedef enum logic [1:0] { ONE, TWO, THREE } enum_t;
  typedef enum_t alias_t;
endpackage
interface ifc;
  pkg::alias_t st = pkg::THREE;
  pkg::alias_t arr [2];
endinterface
module top; ifc u(); endmodule

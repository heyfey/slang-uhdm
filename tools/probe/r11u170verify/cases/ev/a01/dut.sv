// § enumAliasEndAtDimOrInitDecl158
package pkg;
  typedef enum logic [1:0] { ONE, TWO, THREE } enum_t;
  typedef enum_t a1_t;
  typedef a1_t a2_t;
endpackage
module top;
  pkg::a2_t b [3];
  initial b[0] = pkg::TWO;
endmodule

// § enumAliasEndAtDimOrInitDecl158
package pkg;
  typedef enum logic [1:0] { ONE, TWO, THREE } enum_t;
  typedef enum_t alias_t;
endpackage
module sub (input pkg::alias_t p [2], output logic o);
  assign o = (p[0] == pkg::ONE);
endmodule
module top (input pkg::alias_t p [2], output logic o); sub u(.p(p), .o(o)); endmodule

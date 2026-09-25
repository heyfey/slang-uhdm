// § enumAliasEndAtDimOrInitDecl158
package pkg;
  typedef enum logic [1:0] { ONE, TWO, THREE } enum_t;
  typedef enum_t alias_t;
endpackage
module top (output logic [1:0] o);
  function automatic logic [1:0] f();
    pkg::alias_t v = pkg::TWO;
    return v;
  endfunction
  assign o = f();
endmodule

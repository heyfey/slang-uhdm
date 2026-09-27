// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
program z_prog; import p::*; endprogram
module a_mod import p::*; (input logic x);
endmodule

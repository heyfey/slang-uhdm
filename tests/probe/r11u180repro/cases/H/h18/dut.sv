// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
  typedef e_t e2_t;
endpackage
module z_mod import p::*; (input logic y);
endmodule
module a_mod import p::*; (input e2_t x);
endmodule

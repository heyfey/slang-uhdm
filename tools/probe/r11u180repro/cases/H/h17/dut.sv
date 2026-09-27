// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
package q;
  typedef enum logic [2:0] { C, D } e_t;
endpackage
module z_mod import p::*; (input logic y);
endmodule
module m_mod import q::*; (input logic y);
endmodule
module a_mod import q::*; import p::*; (input logic x);
endmodule

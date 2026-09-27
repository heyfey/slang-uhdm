// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module z_mod import p::*; (input logic y);
endmodule
module m_mod import p::*; (input logic y);
endmodule
module a_mod import p::*; (input logic x);
  z_mod u1(.y(x));
  m_mod u2(.y(x));
endmodule

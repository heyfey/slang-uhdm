// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module z_mod import p::*; (input logic y, output e_t o);
  assign o = A;
endmodule
module a_mod import p::*; (input logic x);
  e_t v;
  z_mod u(.y(x), .o(v));
endmodule

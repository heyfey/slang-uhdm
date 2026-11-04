// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module z_mod (input logic y);
  import p::*;
  e_t s;
  always_comb s = e_t'(y);
endmodule
module top (input logic x);
  import p::*;
  e_t t;
  z_mod u1(.y(x));
  z_mod u2(.y(x));
endmodule

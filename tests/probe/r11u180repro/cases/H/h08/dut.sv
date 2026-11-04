// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module z_mod (input logic y);
  import p::e_t;
endmodule
module a_mod (input logic x);
  import p::e_t;
endmodule

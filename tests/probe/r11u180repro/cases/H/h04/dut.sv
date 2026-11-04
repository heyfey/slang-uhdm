// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module top;
  import p::*;
  e_t v;
endmodule

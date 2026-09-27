// § enumImportParentLastWriter180 (verifier: a program zprog and an interface aif import the enum)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
interface aif;
  import p::*;
  e_t s;
endinterface
program zprog;
  import p::*;
  e_t v;
  initial v = B;
endprogram
module top;
  aif i0();
endmodule

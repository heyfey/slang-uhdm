// § enumImportParentLastWriter180 (verifier: two interfaces only, the alphabetically last first in the source)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
interface zif;
  import p::*;
  e_t s;
endinterface
interface aif;
  import p::*;
  e_t t;
endinterface
module top;
  zif z0();
  aif a0();
endmodule

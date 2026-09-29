// § importVarElemOwnName214 — an associative array keyed by a class, of a class, inherited by a $unit class with a nested class
package p;
  class key_c; int k; endclass
  class val_c; int v; endclass
  val_c tab [key_c];
  int iarr [2][3];
endpackage
import p::*;
class outer_c;
  class inner_c; int i; endclass
  int o;
endclass
module top;
  outer_c oc;
endmodule

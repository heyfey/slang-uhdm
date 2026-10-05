// § clsPropSpecPaNoFile243
// a $unit class holding a package generic with data-type arguments, the Scoreboard shape
package p;
  class imp #(type T = int, type IMP = int);
    T a;
  endclass
endpackage
import p::*;
class sb;
  imp #(int, sb) m_imp;
  imp #(logic [7:0]) m_two;
endclass
module top;
  sb s;
endmodule

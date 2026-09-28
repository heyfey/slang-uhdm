// § classSpecExprArgUnlocated202
package p;
  class pc; endclass
endpackage
import p::*;
class loc; endclass
typedef int myint;
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(pc, myint) m_a;
typedef cfg#(loc, cfg#(int,int)) m_b;
module top ();
  m_a a = new;
  m_b b;
  cfg#(pc, myint) c;
  cfg#(loc, p::pc) d;
endmodule

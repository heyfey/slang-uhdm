// § clsPropSpecPaNoFile243
// a holder in a package, a nested specialization argument, and a specialization in a module's class
package p;
  class g1 #(type T = int);
    T a;
  endclass
  class g2 #(type U = int, type V = bit);
    U u; V v;
  endclass
  class holder;
    g2 #(g1 #(int), logic [3:0]) m;
    g1 #(holder) self;
  endclass
endpackage
module top;
  import p::*;
  class mc;
    g1 #(byte) m;
  endclass
  holder h;
  mc o;
endmodule

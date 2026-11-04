// § clsShortRealAliasElem464 (a class in a package with a shortreal alias property)
package p;
  typedef shortreal sr_t;
  class C;
    sr_t d[];
    sr_t q[$:3];
  endclass
endpackage
import p::*;
module top;
  initial begin C c; c = new; end
endmodule

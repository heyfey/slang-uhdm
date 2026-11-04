// § enumTdLastWriter214 § enumClsWriterUnitScopeOnly219 — a $unit import read by a class nested one level inside a $unit class (the nested class a writer after its outer class), and a module
package p;
  typedef enum {M0, M1, M2} mode_e;
  typedef mode_e ALIAS_T;
endpackage
import p::*;
class outer_c;
  class inner_c;
    ALIAS_T a;
  endclass
endclass
module top(output int o);
  ALIAS_T s = M1;
  assign o = int'(s);
endmodule

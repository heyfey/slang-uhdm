// § enumClsWriterUnitScopeOnly219 — a class declared in a module beside a $unit class, both reading a $unit-imported enum: only the $unit class writes
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
endpackage
import p::*;
class u_c;
  ALIAS_T a;
endclass
module top(output int o);
  class m_c;
    ALIAS_T b;
  endclass
  ALIAS_T s = M1;
  assign o = int'(s);
endmodule

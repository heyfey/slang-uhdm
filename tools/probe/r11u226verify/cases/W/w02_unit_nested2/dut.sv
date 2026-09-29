// § enumTdLastWriter214 § enumClsWriterUnitScopeOnly219 — a $unit import read by a class nested two levels deep inside a $unit class, and a module
package p;
  typedef enum {M0, M1, M2} mode_e;
  typedef mode_e ALIAS_T;
endpackage
import p::*;
class outer_c;
  class mid_c;
    class inner_c;
      ALIAS_T a;
      function void set(ALIAS_T v); a = v; endfunction
    endclass
  endclass
endclass
module top(output int o);
  ALIAS_T s = M1;
  assign o = int'(s);
endmodule

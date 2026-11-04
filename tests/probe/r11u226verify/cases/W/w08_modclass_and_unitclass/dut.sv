// § enumTdLastWriter214 § enumClsWriterUnitScopeOnly219 — a class declared inside a module named after the $unit class, the $unit class the writer
package p;
  typedef enum {R0, R1} r_e;
  typedef r_e R_T;
endpackage
import p::*;
class aa_c;
  R_T a;
endclass
module top(output int o);
  class zz_c;
    R_T z;
    function R_T get(); return z; endfunction
  endclass
  R_T s = R1;
  assign o = int'(s);
endmodule

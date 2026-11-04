// § enumTdLastWriter214 — a $unit import read by a $unit class and a module: the class writes after every module
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
endpackage
import p::*;
class mid_c;
  ALIAS_T a;
  function void set(ALIAS_T v); a = v; endfunction
endclass
module top(output int o);
  ALIAS_T s = M1;
  assign o = int'(s);
endmodule

// § enumTdLastWriter214 — a $unit import read by a $unit class holding the alias and by its nested class holding it too, and a second $unit class sorting after both
package p;
  typedef enum logic [1:0] {M0, M1, M2} mode_e;
  typedef mode_e ALIAS_T;
endpackage
import p::*;
class aa_c;
  ALIAS_T x;
  class nn_c;
    ALIAS_T y;
  endclass
endclass
class zz_c;
  ALIAS_T z;
endclass
module top(output int o);
  ALIAS_T s = M2;
  assign o = int'(s);
endmodule

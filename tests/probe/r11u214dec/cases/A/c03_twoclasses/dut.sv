// § enumTdLastWriter214 — a $unit import and two $unit classes, the alphabetically last written first
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
import p::*;
class zz_c;
  int x;
endclass
class aa_c;
  int y;
endclass

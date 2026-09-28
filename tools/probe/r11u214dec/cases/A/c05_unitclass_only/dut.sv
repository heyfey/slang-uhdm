// § enumTdLastWriter214 — Scoreboard's shape: a $unit import and a $unit class, no importing design element
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
import p::*;
class my_sb;
  ALIAS_T a;
endclass

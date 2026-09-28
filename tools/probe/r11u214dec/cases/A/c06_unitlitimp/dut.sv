// § enumTdLastWriter214 — an explicit $unit import of an enum LITERAL and a $unit class (Kmac's explicit-literal shape on the class side)
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
import p::M0;
class my_sb;
  int a;
endclass

// § enumTdLastWriter214 — MiniAmiq's shape: a package importing p with a class, and an interface importing p
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
package q;
  import p::*;
  class qc;
    ALIAS_T a;
  endclass
endpackage
interface ifc;
  import p::*;
  import q::*;
endinterface

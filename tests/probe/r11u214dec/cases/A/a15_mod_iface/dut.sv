// § enumTdLastWriter214 — a module and an interface both import (the interface written before the module)
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
interface ifc;
  import p::*;
endinterface

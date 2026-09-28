// § enumTdLastWriter214 — a05 with an importing module
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

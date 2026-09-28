// § enumTdLastWriter214 — two importing modules, the alphabetically first written last
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
module zz;
  import p::*;
endmodule
module aa;
  import p::*;
endmodule

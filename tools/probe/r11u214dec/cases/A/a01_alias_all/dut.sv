// § enumTdLastWriter214 — the ref_typespec under an enum alias typedef (typedef mode_e ALIAS_T) read in every context, one importer
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  function automatic int pf(ALIAS_T v); return int'(v); endfunction
  class c;
    ALIAS_T cv;
    function void set(ALIAS_T val); cv = val; endfunction
  endclass
endpackage
module top(output int o);
  import p::*;
  ALIAS_T mv;
  assign o = pf(mv);
endmodule

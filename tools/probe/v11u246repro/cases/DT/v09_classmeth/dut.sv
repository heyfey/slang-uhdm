// § dpiTopCastResolvesByModImport246
package p;
  typedef enum {A0, A1, A2} e_t;
  class rh;
    function void report(e_t v); endfunction
  endclass
  rh h;
  export "DPI-C" function m_dpi;
  function void m_dpi(int v);
    e_t loc;
    loc = e_t'(v);
    h.report(e_t'(v + 1));
  endfunction
endpackage
module top;
  import p::*;
  initial m_dpi(1);
endmodule

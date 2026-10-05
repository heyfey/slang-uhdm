// § dpiTopCastResolvesByModImport246
`define IMP(P) import P::*;
package p;
  typedef enum {A0, A1, A2} e_t;
  function void report(e_t v);
  endfunction
  export "DPI-C" function m_dpi;
  function void m_dpi(int v);
    report(e_t'(v));
  endfunction
endpackage
module top;
  `IMP(p)
  e_t q;
endmodule

// § dpiTopCastResolvesByModImport246
package p;
  typedef enum {A0, A1} e_t;
  typedef int other_t;
  function void report(e_t v);
  endfunction
  export "DPI-C" function m_dpi;
  function void m_dpi(int v);
    report(e_t'(v));
  endfunction
endpackage
module top;
  import p::other_t;
  other_t z;
endmodule

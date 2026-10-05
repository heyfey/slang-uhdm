// § dpiTopCastResolvesByModImport246
package p;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  function void report(st_t v);
  endfunction
  export "DPI-C" function m_dpi;
  function void m_dpi(int v);
    report(st_t'(v));
  endfunction
endpackage
module child;
  import p::*;
  st_t r;
  assign r = st_t'(5);
endmodule
module top;
  wire impl_n;
  assign impl_x = impl_n;
  child u();
endmodule

// § dpiTopCastResolvesByModImport246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  typedef struct packed { bit [1:0] a; } st_e;
  class rep;
    virtual function void mrep(sev_e severity, string id);
    endfunction
  endclass
  function void report(sev_e severity, string id);
  endfunction
  export "DPI-C" function m_dpi;
  function void m_dpi(int severity, string id);
    report(sev_e'(severity), id);
    report(sev_e'(st_e'(severity)), id);
  endfunction
endpackage
module top;
  import p::*;
  assign imp_net = 1'b0;
  sev_e x;
  initial x = sev_e'(1);
endmodule

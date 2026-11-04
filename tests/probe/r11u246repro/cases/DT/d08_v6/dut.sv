// § dpiTopCastResolvesByModImport246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  function void report(sev_e severity, string id);
  endfunction
  class rep;
    virtual function void mrep(sev_e severity, string id);
    endfunction
  endclass
  class rep2;
    sev_e s2;
    function void mrep2(sev_e severity);
    endfunction
  endclass
  export "DPI-C" function m_dpi;
  function void m_dpi(int severity, string id);
    report(sev_e'(severity), id);
  endfunction
endpackage
import p::*;
module top;
endmodule

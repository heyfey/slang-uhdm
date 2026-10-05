// § dpiTopCastResolvesByModImport246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  function void report(sev_e severity, string id);
  endfunction
  class aa;
    function void ma(sev_e severity);
    endfunction
    function sev_e mr();
    endfunction
    task mt(input sev_e s);
    endtask
  endclass
  export "DPI-C" function m_dpi;
  function void m_dpi(int severity, string id);
    report(sev_e'(severity), id);
  endfunction
  function void report2(sev_e severity);
  endfunction
endpackage
import p::*;
module top;
endmodule

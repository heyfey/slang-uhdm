// § dpiTopCastResolvesByModImport246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  function void report(sev_e severity, string id);
  endfunction
  export "DPI-C" function m_dpi;
  function void m_dpi(int severity, string id);
    report(sev_e'(severity), id);
  endfunction
endpackage
interface ifc;
  logic v;
  function automatic logic get(); return v; endfunction
endinterface
module top;
  import p::*;
  ifc i0();
  assign impl_n = i0.v;
  assign i0.v = 1'b1;
endmodule

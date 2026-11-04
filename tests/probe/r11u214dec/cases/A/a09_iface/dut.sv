// § enumTdLastWriter214 — the importer is an interface (MiniAmiq's svaunit_vpi_interface shape)
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
interface ifc;
  import p::*;
endinterface

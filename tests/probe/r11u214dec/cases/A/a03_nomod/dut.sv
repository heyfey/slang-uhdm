// § enumTdLastWriter214 — the extern-method shape of a02 with no importer (BuildUVMPkg's shape: the package alone)
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    extern function void set(ALIAS_T val);
    extern function ALIAS_T get();
  endclass
  function void c::set(ALIAS_T val); m = val; endfunction
  function ALIAS_T c::get(); return m; endfunction
endpackage

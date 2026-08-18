// vbuvm13 arm a4 — THE CLONE FAMILIES the v3 arm does not reach: a CLASS whose
// methods a wildcard import materialises in the importing package (the
// `cloneMode` / pkgClassTfClone path, which the shipped fence
// `pkgImportCloneEmit || importCloneEmit` does NOT name), an EXPLICIT
// (non-wildcard) import, a package imported by TWO packages, and a
// $unit-scope class.
package ph4;
  typedef enum int {H4_A = 1, H4_B = 2} h4_t;
  int hv4 = 3;
  function int hr4(int x); return x; endfunction
  function automatic int hf_earlier(int a, int b = a);      return a+b; endfunction
  function automatic int hf_enumi(int v = H4_B);            return v; endfunction
  class hc4;
    function int hm_earlier(int a, int b = a);              return a+b; endfunction
    function int hm_enumi(int v = H4_B);                    return v; endfunction
    extern function int hx_earlier(int a, int b = a);
    extern function int hx_call(int a, int b = hr4(a));
  endclass
  function int hc4::hx_earlier(int a, int b = a);           return a+b; endfunction
  function int hc4::hx_call(int a, int b = hr4(a));         return a+b; endfunction
endpackage

// WILDCARD importer
package pw4;
  import ph4::*;
  function automatic int w_use(int a); return hf_earlier(a); endfunction
endpackage

// EXPLICIT (non-wildcard) importer
package pe4;
  import ph4::hf_earlier;
  import ph4::hc4;
  function automatic int e_use(int a); return hf_earlier(a); endfunction
endpackage

// a SECOND wildcard importer of the same package
package pw4b;
  import ph4::*;
  function automatic int w2_use(int a); return hf_earlier(a); endfunction
endpackage

// $unit-scope class
class uc4;
  function int um_earlier(int a, int b = a);                return a+b; endfunction
  extern function int ux_earlier(int a, int b = a);
endclass
function int uc4::ux_earlier(int a, int b = a);             return a+b; endfunction
function automatic int uf4_earlier(int a, int b = a);       return a+b; endfunction

module m_a4;
  import pw4::*;
  import pe4::*;
  import pw4b::*;
  ph4::hc4 h;
  uc4 u;
  int z;
  initial begin
    h = new(); u = new();
    z = w_use(1); z = e_use(1); z = w2_use(1);
    z = ph4::hf_earlier(1); z = ph4::hf_enumi();
    z = h.hm_earlier(1); z = h.hm_enumi(); z = h.hx_earlier(1); z = h.hx_call(1);
    z = u.um_earlier(1); z = u.ux_earlier(1); z = uf4_earlier(1);
  end
endmodule

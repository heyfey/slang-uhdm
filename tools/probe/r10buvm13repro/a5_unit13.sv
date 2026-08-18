// vbuvm13 arm a5 — the $unit REACH and the EXPLICIT-IMPORT clone, with the
// ENUM-CONSTANT cell next to the EARLIER-FORMAL cell in every site, so the two
// halves of the silence can be told apart.
package pu5;
  typedef enum int {U5_A = 1, U5_B = 2} u5_t;
  int pv5 = 1;
  function int r5(int x); return x; endfunction
  function automatic int hf_earlier(int a, int b = a);   return a+b; endfunction
  function automatic int hf_enumi(int v = U5_B);         return v; endfunction
  task automatic ht_earlier(input int a, input int b = a); endtask
endpackage

// EXPLICIT single-name imports of a FUNCTION and a TASK
package pex5;
  import pu5::hf_earlier;
  import pu5::hf_enumi;
  import pu5::ht_earlier;
  function automatic int ex_use(int a); return hf_earlier(a); endfunction
endpackage

// $unit scope: free function/task, a class (in-body + extern/out-of-body),
// each with an EARLIER-FORMAL cell and an ENUM-CONSTANT cell.
typedef enum int {G5_A = 1, G5_B = 2} g5_t;
function automatic int gu_earlier(int a, int b = a);     return a+b; endfunction
function automatic int gu_enumi(int v = G5_B);           return v; endfunction
task automatic gt_earlier(input int a, input int b = a);  endtask
class gc5;
  function int gm_earlier(int a, int b = a);             return a+b; endfunction
  function int gm_enumi(int v = G5_B);                   return v; endfunction
  extern function int gx_earlier(int a, int b = a);
  extern function int gx_enumi(int v = G5_B);
  extern function int gx_call(int a, int b = pu5::r5(a));
endclass
function int gc5::gx_earlier(int a, int b = a);          return a+b; endfunction
function int gc5::gx_enumi(int v = G5_B);                return v; endfunction
function int gc5::gx_call(int a, int b = pu5::r5(a));    return a+b; endfunction

module m_a5;
  import pex5::*;
  gc5 g;
  int z;
  initial begin
    g = new();
    z = ex_use(1);
    z = pex5::hf_earlier(1); z = pex5::hf_enumi(); pex5::ht_earlier(1);
    z = gu_earlier(1); z = gu_enumi(); gt_earlier(1);
    z = g.gm_earlier(1); z = g.gm_enumi();
    z = g.gx_earlier(1); z = g.gx_enumi(); z = g.gx_call(1);
  end
endmodule

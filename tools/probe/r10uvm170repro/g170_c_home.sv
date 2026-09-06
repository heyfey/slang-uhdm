// r10uvm170 arm C — THE HOME + ORDER + SCOPE axes.
//   * home:  same package / foreign package / $unit
//   * order: the export written ABOVE vs BELOW the definition
//   * scope: package / module / interface / class-in-package / $unit
// A `$unit` typedef and a MODULE-scope DPI export are the two "an arm agreeing
// is not an arm testing" traps here: both must stay RESOLVED on both sides.
typedef enum bit [1:0] { U0, U1 } eu_t;        // $unit typedef

package fc170;
  typedef enum bit [1:0] { FC0, FC1 } fc_t;
endpackage

package pc170;
  typedef enum bit [1:0] { C0, C1 } ec_t;
  typedef enum bit [1:0] { C2, C3 } ed_t;
  function void snk_c(int q);
  endfunction

  // (1) export ABOVE the definition — the corpus order
  export "DPI-C" function fabove_c;
  function void fabove_c(int s);
    snk_c(int'(ec_t'(s)));            // f01 same package     -> DEGRADES
    snk_c(int'(fc170::fc_t'(s)));     // f02 foreign, scoped  -> resolves
  endfunction

  // (2) export BELOW the definition — must change nothing
  function void fbelow_c(int s);
    snk_c(int'(ec_t'(s)));            // g01
    snk_c(int'(fc170::fc_t'(s)));     // g02
  endfunction
  export "DPI-C" function fbelow_c;

  // (3) an exported subroutine whose name is NOT the one exported
  export "DPI-C" function fother_c;
  function void fother_c(int s);
    snk_c(int'(ed_t'(s)));            // h01 -> DEGRADES
  endfunction
  function void fneigh_c(int s);      // never exported
    snk_c(int'(ed_t'(s)));            // h02 -> resolves
  endfunction

  // (4) a CLASS method inside the same package, exported name collision
  class cc170;
    function void m(int s);
      snk_c(int'(ec_t'(s)));          // h03 -> resolves (class scope)
    endfunction
  endclass
endpackage

module mod_c170;
  typedef enum bit [1:0] { M0, M1 } em_t;
  function void snk_m(int q);
  endfunction
  export "DPI-C" function fmod_c;
  function void fmod_c(int s);
    snk_m(int'(em_t'(s)));            // i01 module-scope export -> resolves
    snk_m(int'(pc170::ec_t'(s)));     // i02
    snk_m(int'(eu_t'(s)));            // i03
  endfunction
  function void fmodp_c(int s);
    snk_m(int'(em_t'(s)));            // j01
    snk_m(int'(pc170::ec_t'(s)));     // j02
    snk_m(int'(eu_t'(s)));            // j03
  endfunction
  initial fmodp_c(1);
endmodule

interface if_c170;
  typedef enum bit [1:0] { I0, I1 } ei_t;
  function void snk_i(int q);
  endfunction
  export "DPI-C" function fif_c;
  function void fif_c(int s);
    snk_i(int'(ei_t'(s)));            // k01 interface-scope export
  endfunction
endinterface

module top_c170;
  if_c170 u_if();
  mod_c170 u_m();
  initial pc170::fbelow_c(1);
endmodule

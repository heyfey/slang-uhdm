// v136 arm J — DOWNSTREAM USES of a packed-struct property: constraints,
// covergroups, method bodies, signed packed structs, shadowed names,
// a class in a generate block.
package Pk_Uses;
  typedef struct packed { bit [7:0] lo8; bit [7:0] hi8; }            useSpan_S;
  typedef struct packed signed { bit [7:0] sLo; bit [7:0] sHi; }     signSpan_S;
  typedef union  packed { bit [15:0] wWhole; bit [15:0] wAlt; }      useWrap_U;

  class Constrained;
    rand useSpan_S  j01_randSpan;
    rand bit [7:0]  j02_randBits;
    rand useWrap_U  j03_randWrap;
    constraint c_span { j01_randSpan.lo8 < 8'd100; j01_randSpan.hi8 > 8'd1; }
    constraint c_mix  { j02_randBits inside {[0:255]}; j03_randWrap.wWhole != 16'd0; }
  endclass

  class Covered;
    useSpan_S j04_covSpan;
    covergroup cg_span;
      cp_lo : coverpoint j04_covSpan.lo8;
      cp_hi : coverpoint j04_covSpan.hi8;
    endgroup
    function new(); cg_span = new(); endfunction
  endclass

  class Methoded;
    useSpan_S  j05_read;
    signSpan_S j06_signed;
    useWrap_U  j07_wrap;
    function useSpan_S get_span();
      get_span = j05_read;
    endfunction
    function void set_span(input useSpan_S v);
      j05_read = v;
      j05_read.lo8 = v.hi8;
      j07_wrap.wWhole = {j06_signed.sHi, j06_signed.sLo};
    endfunction
    task automatic touch();
      useSpan_S loc_span;         // a LOCAL of the same face (not a property)
      loc_span = j05_read;
      j05_read = loc_span;
    endtask
  endclass

  class ShadowBase;
    useSpan_S j08_shadowed;
  endclass
  class ShadowDerived extends ShadowBase;
    useWrap_U j09_own;
  endclass
endpackage

module mod_uses_top;
  import Pk_Uses::*;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      class GenCls;
        useSpan_S j10_genProp;
      endclass
      GenCls u_gen;
    end
  endgenerate
  Constrained u_con;
  Covered     u_cov;
  Methoded    u_met;
  ShadowDerived u_shd;
endmodule

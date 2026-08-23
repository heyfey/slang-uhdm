// r10uvm114 arm C — typedefs inside a CLASS declared in a PACKAGE, and an
// out-of-body method's local typedef.
`define WID114 32

package brine114_pkg;
  parameter int Span = 12;

  class Kelp114;
    typedef bit   [`WID114-1:0] clsmac_t;
    typedef logic [32-1:0]      clslit_t;
    typedef bit   [Span-1:0]    clsspan_t;
    typedef bit   [7:0]         clsoct_t;
    bit  [32-1:0]  clsfield;
    logic [Span-1:0] clswide;
    extern function bit [32-1:0] chew();
  endclass

  function bit [32-1:0] Kelp114::chew();
    typedef bit [32-1:0] localmac_t;
    localmac_t lv = 0;
    return lv;
  endfunction

  function automatic logic [Span-1:0] pkgfn(input bit [32-1:0] arg);
    typedef bit [32-1:0] fnlocal_t;
    fnlocal_t fv = arg;
    return fv[Span-1:0];
  endfunction
endpackage

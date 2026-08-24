// r10v123 arm B — the BOUND grid: macro-expanded / parameter / literal /
// localparam / $bits bounds on bit and logic package typedefs, cast BARE from
// the home package's function, a class in the home package, another package
// (wildcard import AND explicit import), module scope, a module subroutine and
// an interface subroutine.
`define CEDAR_MW123 12
package cedar123_pkg;
  parameter  int CEDAR_PW = 9;
  localparam int CEDAR_LW = 5;
  typedef bit   [`CEDAR_MW123-1:0] cedar_macro_t;
  typedef logic [CEDAR_PW-1:0]     cedar_param_t;
  typedef bit   [6:0]              cedar_lit_t;
  typedef logic [CEDAR_LW-1:0]     cedar_local_t;
  typedef bit   signed [11:0]      cedar_sgn_t;
  function automatic int cedar_home(int qq);
    cedar_macro_t a1; cedar_param_t b1; cedar_lit_t c1;
    cedar_local_t d1; cedar_sgn_t   e1;
    a1 = cedar_macro_t'(qq);
    b1 = cedar_param_t'(qq);
    c1 = cedar_lit_t'(qq);
    d1 = cedar_local_t'(qq);
    e1 = cedar_sgn_t'(qq);
    return int'(a1) + int'(b1) + int'(c1) + int'(d1) + int'(e1);
  endfunction
  class CedarCls;
    function int cm(int qq);
      cedar_macro_t a2; cedar_param_t b2; cedar_lit_t c2;
      a2 = cedar_macro_t'(qq);
      b2 = cedar_param_t'(qq);
      c2 = cedar_lit_t'(qq);
      return int'(a2) + int'(b2) + int'(c2);
    endfunction
  endclass
endpackage

package dogwood123_pkg;                 // WILDCARD importer
  import cedar123_pkg::*;
  function automatic int dogwood_use(int qq);
    cedar_macro_t a3; cedar_param_t b3; cedar_lit_t c3;
    a3 = cedar_macro_t'(qq);
    b3 = cedar_param_t'(qq);
    c3 = cedar_lit_t'(qq);
    return int'(a3) + int'(b3) + int'(c3);
  endfunction
endpackage

package elm123_pkg;                     // EXPLICIT importer
  import cedar123_pkg::cedar_macro_t;
  import cedar123_pkg::cedar_param_t;
  function automatic int elm_use(int qq);
    cedar_macro_t a4; cedar_param_t b4;
    a4 = cedar_macro_t'(qq);
    b4 = cedar_param_t'(qq);
    return int'(a4) + int'(b4);
  endfunction
endpackage

interface fir123_if;
  import cedar123_pkg::*;
  function automatic int fir_sub(int qq);
    cedar_macro_t a5; cedar_param_t b5;
    a5 = cedar_macro_t'(qq);
    b5 = cedar_param_t'(qq);
    return int'(a5) + int'(b5);
  endfunction
endinterface

module cedar_top;
  import cedar123_pkg::*;
  cedar_macro_t wmod;
  cedar_param_t xmod;
  cedar_lit_t   ymod;
  assign wmod = cedar_macro_t'(7);
  assign xmod = cedar_param_t'(5);
  assign ymod = cedar_lit_t'(3);
  function automatic int cedar_sub(int qq);
    cedar_macro_t a6; cedar_param_t b6;
    a6 = cedar_macro_t'(qq);
    b6 = cedar_param_t'(qq);
    return int'(a6) + int'(b6);
  endfunction
  fir123_if fifc();
  initial begin
    int rr;
    rr = cedar_home(1) + dogwood123_pkg::dogwood_use(2) +
         elm123_pkg::elm_use(3) + cedar_sub(4) + fifc.fir_sub(5);
  end
endmodule

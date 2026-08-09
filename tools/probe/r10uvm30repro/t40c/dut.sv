// t40c — the last cells of the § noDirNamedTypeDefaultDropped30 boundary.
// t40a/t40b fixed the law at "no direction keyword + the data type written as
// a SIMPLE type IDENTIFIER".  The spellings that are neither a bare
// identifier nor a builtin keyword are here: a PARAMETERISED class name
// (`cls#(int)`), a `virtual` interface, a typedef of a builtin (string), the
// `var` keyword with no direction, and the explicit output/inout directions.
interface if40c;
  logic x;
endinterface

package p40c;
  typedef enum int { E0, E1 } e40_t;
  typedef string s40_t;
  class pc40 #(type T = int); T z; endclass
  typedef pc40#(int) pcint_t;

  class c40c;
    // parameterised class handle, NO direction
    function void b_param_cls (      pc40#(int) h = null); endfunction
    function void i_param_cls (input pc40#(int) h = null); endfunction
    // a typedef OF a parameterised class (still a simple identifier)
    function void b_td_cls    (      pcint_t h = null); endfunction
    // typedef of a BUILTIN, still a simple identifier
    function void b_td_str    (      s40_t s = "x"); endfunction
    function void i_td_str    (input s40_t s = "x"); endfunction
    // `var` keyword, no direction
    function void b_var_enum  (var   e40_t e = E1); endfunction
    function void b_var_int   (var   int   k = 3);  endfunction
    // (an output/inout default must be an LVALUE, so `output e40_t e = E1`
    //  will not compile; the explicit-direction half of the law is settled by
    //  t40a's `input` cells.)
    // named type with an unpacked dimension on the FORMAL, no direction
    function void b_dim_enum  (      e40_t e [2]); endfunction
    // a virtual interface, no direction
    function void b_vif       (      virtual if40c vi = null); endfunction
    function void i_vif       (input virtual if40c vi = null); endfunction
    // the other two `= null`-capable BUILT-IN types: the rule being replaced
    // dropped every no-direction `null`, so both must be read explicitly.
    function void b_chandle   (      chandle h = null); endfunction
    function void i_chandle   (input chandle h = null); endfunction
    function void b_event     (      event   e = null); endfunction
    function void i_event     (input event   e = null); endfunction
    // REAL defaults at every spelling: § classPropRealInitRawValue29 said a
    // class PROPERTY's real initializer prints its SOURCE TEXT; the io_decl
    // arm still renders %f (`REAL:1.500000`), and two UVM formals reach it.
    function void r_half      (      real  r = 1.5);    endfunction
    function void r_exp       (      real  r = 1.0e-9); endfunction
    function void r_int       (      real  r = 3.0);    endfunction
    function void r_neg       (      real  r = -2.5);   endfunction
    function void r_in        (input real  r = 1.5);    endfunction
    function void r_time      (      realtime r = 1.0e-9); endfunction
    function void r_shortreal (      shortreal r = 1.5); endfunction
    // a named type default written as a CAST and as an expression
    function void b_cast      (      e40_t e = e40_t'(1)); endfunction
    function void b_expr      (      int   k = 1 + 2);     endfunction
    function void b_tdexpr    (      p40c::e40_t e = E1);  endfunction
  endclass
endpackage

module top40c;
  import p40c::*;
  c40c c;
  initial c = new();
endmodule

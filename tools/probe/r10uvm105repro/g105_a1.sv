// r10uvm105 arm a1 — MEASUREMENT ONLY.  The type-parameter TYPESPEC grid for a
// PACKAGE class: every declaration site x in-body vs OUT-OF-BODY, for the
// class's OWN type parameter (T), a parameter DEFAULTED FROM another parameter
// (U = T), a typedef OF the parameter (my_t), an INT-defaulted parameter (W),
// and the controls that must NOT move (a plain class name, a plain typedef, a
// value parameter).
package p105;

  class d105a;   int dx; endclass
  class e105a;   int ex; endclass

  typedef int    plain105_t;

  class c105 #(type T = d105a, type U = T, type W = int);
    typedef T      my_t;      // a typedef OF the type parameter
    typedef d105a  cd_t;      // a plain typedef, the control

    // ---- in-body PROPERTIES ------------------------------------------------
    T           pr_t;
    U           pr_u;
    W           pr_w;
    my_t        pr_td;
    d105a       pr_cls;       // control
    plain105_t  pr_pln;       // control

    // ---- in-body METHOD, every site ---------------------------------------
    function d105a ib_all(input T fa, input U fb, input W fc,
                          input my_t fd, input d105a fe, input plain105_t ff);
      T          lo_t;
      U          lo_u;
      W          lo_w;
      my_t       lo_td;
      d105a      lo_cls;
      plain105_t lo_pln;
      return fe;
    endfunction

    // in-body method whose RETURN type is the type parameter
    function T ib_ret(input T fa);
      T r_t;
      return r_t;
    endfunction

    // ---- the OUT-OF-BODY prototypes ---------------------------------------
    extern function void  oob_all(input T fa, input U fb, input W fc,
                                  input my_t fd, input d105a fe,
                                  input plain105_t ff);
    extern function T     oob_ret(input T fa);
    extern function void  oob_loc();
    extern task           oob_task(input T fa);
    extern static function void oob_stat(input T fa);
  endclass

  // ---- the OUT-OF-BODY DEFINITIONS, compiled in the PACKAGE's scope --------
  function void c105::oob_all(input T fa, input U fb, input W fc,
                              input my_t fd, input d105a fe,
                              input plain105_t ff);
    T          xo_t;
    U          xo_u;
    W          xo_w;
    my_t       xo_td;
    d105a      xo_cls;
    plain105_t xo_pln;
  endfunction

  // LRM: an out-of-block RETURN type naming a class-scoped name must be
  // written `c105::T` — slang REJECTS the bare `T` here, so the RETURN cell is
  // necessarily the SCOPED spelling.
  function c105::T c105::oob_ret(input T fa);
    T yo_t;
    return yo_t;
  endfunction

  function void c105::oob_loc();
    T          zo_t;
  endfunction

  task c105::oob_task(input T fa);
    T          to_t;
  endtask

  function void c105::oob_stat(input T fa);
    T          so_t;
  endfunction

endpackage

module top105;
  import p105::*;
  c105 #(e105a)          h_spec;
  c105                   h_gen;
  initial begin
    h_spec = new();
    h_gen  = new();
  end
endmodule

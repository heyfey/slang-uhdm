// r10uvm153 arm C — THE HOMES, and the three BARE positions asked of a REAL
// package variable (not a class property), which is where OUR emitter's
// § pkgVarBindsOnlyThroughInstance88 binder already runs.  LHS is golden.
package pc153;

  class Kc153;
    int fc;
    function void kc(); endfunction
  endclass

  int   c_int;
  Kc153 c_h;
  Kc153 c_recv;
  Kc153 c_newv;

  class Dc153;
    int   c_int;
    Kc153 c_h;
    Kc153 c_recv;
    Kc153 c_newv;
    extern function void oob153(int p);
    function void inb153(int p);        // IN-BODY: no vpiInstance (§ 88)
      c_int = p;
    endfunction
  endclass

  function void Dc153::oob153(int p);
    c_int = p;
    c_h.fc = p;
    c_recv.kc();
    c_newv = new();
  endfunction

  // A package FREE function reading REAL package variables from the same
  // three positions: this is the control for our own § 88 binder.
  function void free153(int p);
    c_int = p;
    c_h.fc = p;
    c_recv.kc();
    c_newv = new();
  endfunction

endpackage

// $unit-scope class: no package in the scope chain at all.
class Uc153;
  int c_int;
  extern function void uoob153(int p);
endclass
function void Uc153::uoob153(int p);
  c_int = p;
endfunction

module mc153;
  int c_int;                       // a MODULE variable of the colliding name
  class Mc153;
    int c_int;
    extern function void moob153(int p);
  endclass
  function void Mc153::moob153(int p);
    c_int = p;                     // a MODULE class: Surelog's uhdmpackage guard
  endfunction
  Mc153 h = new();
  initial h.moob153(1);
endmodule

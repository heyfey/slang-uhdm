// r10uvm144 arm E — the CONSTRUCTOR fence sub-grid (§ ctorBodyLocalsNotOnFunc71
// removes the listing `bindVariable` would have to find), plus its controls.
package p144e;

  class B144;
    extern static function void qint(ref int a[$]);
    extern static function void scal(ref int a);
  endclass
  function void B144::qint(ref int a[$]); endfunction
  function void B144::scal(ref int a); endfunction

  function automatic void bare144(ref int a[$]); endfunction
  function automatic void bares144(ref int a); endfunction

  // e01: ctor, ONE statement, subroutine local, SCOPED call
  class C01; int w; function new(); int vc01[$]; B144::qint(vc01); endfunction endclass
  // e02: ctor, TWO statements (body blockifies), subroutine local, SCOPED call
  class C02; int w; function new(); int vc02[$]; B144::qint(vc02); w = 2; endfunction endclass
  // e03: ctor, FORMAL argument, SCOPED call
  class C03; int w; function new(int f); B144::scal(f); w = 3; endfunction endclass
  // e04: ctor, local of an UNNAMED BLOCK at the same depth, SCOPED call
  class C04; int w; function new(); if (1) begin int vc04[$]; B144::qint(vc04); w = 4; end endfunction endclass
  // e05: ctor, subroutine local, BARE call (the pre-existing control)
  class C05; int w; function new(); int vc05[$]; bare144(vc05); w = 5; endfunction endclass
  // e06: ctor, FORMAL, BARE call (control)
  class C06; int w; function new(int f); bares144(f); w = 6; endfunction endclass
  // e07: OUT-OF-BODY ctor, subroutine local, SCOPED call
  class C07; int w; extern function new(); endclass
  function C07::new(); int vc07[$]; B144::qint(vc07); w = 7; endfunction
  // e08: ORDINARY method control (must bind)
  class C08; int w; function void m(); int vc08[$]; B144::qint(vc08); w = 8; endfunction endclass
  // e09: ctor with an ESCAPED-identifier twin (\new is an ORDINARY method)
  class C09; int w; function int \new (int a); int vc09[$]; B144::qint(vc09); return a; endfunction endclass
  // e10: ctor calling with super.new first
  class C10base; int w; function new(); w = 0; endfunction endclass
  class C10 extends C10base; function new(); int vc10[$]; super.new(); B144::qint(vc10); endfunction endclass

endpackage

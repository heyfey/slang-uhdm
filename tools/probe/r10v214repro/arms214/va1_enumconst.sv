// v214 arm 1 — REFERENT KIND: enum constant and localparam, read from an
// out-of-body class-method clone body.  The law's outer gate is
// `nv.symbol.kind == SymbolKind::Parameter`, so an EnumValue must not move.
package pv1;
  parameter int e_pa = 3;
  localparam int e_lp = e_pa + 1;
  typedef enum int { EV_A = 7, EV_B = 9 } ev_e;
  function automatic int sink1(int a, int b); return a + b; endfunction
  class C1;
    extern function int rd1();
    extern function ev_e rd2();
  endclass
  function int C1::rd1();
    int r;
    r = sink1(EV_A, e_lp);
    r = r + EV_B + e_pa;
    return r;
  endfunction
  function pv1::ev_e C1::rd2();
    return EV_B;
  endfunction
endpackage
module topv1;
  pv1::C1 c = new();
  int x;
  initial x = c.rd1();
endmodule

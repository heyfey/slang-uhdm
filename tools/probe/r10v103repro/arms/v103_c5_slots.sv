// r10v103 arm c5 — EMPTY ARGUMENT SLOTS (buvm24 § emptyArgSlotIntZero24) and
// `void'()` over a DOTTED call, both inside a bad-expression shell.
// MEASUREMENT ONLY.
package Pc8;
  class Lf8;
    int uu;
    function void p3(int aa = 1, int bb = 2, int cc = 3); uu = aa+bb+cc; endfunction
    function int  g1(int aa = 1); return aa; endfunction
  endclass
  class Md8; Lf8 slot; function new(); slot = new(); endfunction endclass
  class Sl8 #(type PT = int);
    Md8 bo; Lf8 el; PT tp; int kk;
    function new(); bo = new(); el = new(); endfunction
    function void E1(); el.p3( 1, , 3 );                  endfunction
    function void E2(); el.p3( , , tp.conv(kk) );         endfunction
    function void E3(); bo.slot.p3( 1, , tp.conv(kk) );   endfunction
    function void V1(); void'( el.g1( tp.conv(kk) ) );    endfunction
    function void V2(); void'( bo.slot.g1( kk ) );        endfunction
  endclass
endpackage

// r10v144 (VERIFIER) arm A — § scopedCallArgsBindLikeBareCall144's WINDOW over
// every HOME and POSITION the implementer's arm C did not spell, and over the
// three local-declaration objects that reach `refVarLocalNoBind5` (a `ref_var`
// local), which the window ALSO flips and which arm C never built.
package q144a;
  typedef class FWD144;                       // forward-declared
  class B144;
    extern static function void si(input int a);
    extern static function void sq(input int a[$]);
    extern static function int  sf(input int a);
    extern static task          st(input int a);
    extern static function void sh(input FWD144 a);
  endclass
  function void B144::si(input int a); endfunction
  function void B144::sq(input int a[$]); endfunction
  function int  B144::sf(input int a); return a; endfunction
  task          B144::st(input int a); endtask
  function void B144::sh(input FWD144 a); endfunction
  class FWD144; int z; endclass

  function automatic void bare144(input int a); endfunction

  // a01 in-body class FUNCTION, statement position (the head's shape)
  class A01; int w; function void m(); int x; B144::si(x); w = 1; endfunction endclass
  // a02 in-body class TASK, statement position
  class A02; int w; task t(); int x; B144::st(x); w = 2; endtask endclass
  // a03 OUT-OF-BODY class method
  class A03; int w; extern function void m(); endclass
  function void A03::m(); int x; B144::si(x); w = 3; endfunction
  // a04 PACKAGE FREE function
  function automatic void pf04(); int x; B144::si(x); endfunction
  // a05 in-body STATIC class method
  class A05; static function void sm(); int x; B144::si(x); endfunction endclass
  // a06 in-body method, local of an UNNAMED begin at the SAME depth
  class A06; int w; function void m(); begin int y; B144::si(y); end w = 6; endfunction endclass
  // a07 in-body method, local of a NAMED begin
  class A07; int w; function void m(); begin : nb07 int y; B144::si(y); end w = 7; endfunction endclass
  // a08 in-body task, a FORK arm
  class A08; int w; task t(); fork begin int y; B144::st(y); end join_none w = 8; endtask endclass
  // a09 in-body method, ONE CONTROL BODY DEEPER
  class A09; int w; function void m(); int x; if (w == 0) B144::si(x); w = 9; endfunction endclass
  // a10 in-body method, EXPRESSION position
  class A10; int w; function int m(); int x; int r; r = B144::sf(x); return r; endfunction endclass
  // a11 in-body method, a CLASS PROPERTY argument
  class A11; int p; function void m(); B144::si(p); p = 11; endfunction endclass
  // a12 in-body method, a FORMAL argument
  class A12; int w; function void m(int f); B144::si(f); w = 12; endfunction endclass
  // a13 in-body method, a FORWARD-DECLARED class handle local
  class A13; int w; function void m(); FWD144 h; B144::sh(h); w = 13; endfunction endclass
  // a14 in-body method, a QUEUE local
  class A14; int w; function void m(); int q[$]; B144::sq(q); w = 14; endfunction endclass
  // a15 in-body method, the argument is an OPERATION over the local
  class A15; int w; function void m(); int x; B144::si(x + 1); w = 15; endfunction endclass
  // a16 in-body method, the local is read inside a $display in the argument list
  class A16; int w; function void m(); int x; $display("%0d", x); B144::si(x); w = 16; endfunction endclass
  // a17 the receiver-less CONTROL twin of a01
  class A17; int w; function void m(); int x; bare144(x); w = 17; endfunction endclass
  // a18 a nested scoped call inside a scoped call's argument
  class A18; int w; function void m(); int x; B144::si(B144::sf(x)); w = 18; endfunction endclass
endpackage

// a19..a21 — MODULE homes.
module m144a;
  import q144a::*;
  int mw;
  function automatic void mf19(); int x; B144::si(x); endfunction
  task automatic mt20(); int x; B144::st(x); endtask
  initial begin
    int x21;
    B144::si(x21);
    mw = 21;
  end
  // a22 a MODULE CLASS's in-body method
  class M22; int w; function void m(); int x; B144::si(x); w = 22; endfunction endclass
endmodule

// a23 — INTERFACE home.
interface i144a;
  import q144a::*;
  int iw;
  function automatic void iff23(); int x; B144::si(x); endfunction
  class I24; int w; function void m(); int x; B144::si(x); w = 24; endfunction endclass
endinterface

// a25 — PROGRAM home.
program pr144a;
  import q144a::*;
  int pw;
  function automatic void pff25(); int x; B144::si(x); endfunction
  initial begin
    int x26;
    B144::si(x26);
    pw = 26;
  end
endprogram

// a27 — $unit home.
import q144a::*;
function automatic void uf27(); int x; B144::si(x); endfunction
class U28; int w; function void m(); int x; B144::si(x); w = 28; endfunction endclass

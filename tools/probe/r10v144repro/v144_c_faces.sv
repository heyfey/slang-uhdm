// r10v144 (VERIFIER) arm C — the BODY-LOCAL FACE × DECLARATION-SITE grid the
// brief names, in ORDINARY (non-constructor) methods, read through a
// class-scope-qualified call.  Its job is to catch the WINDOW over-firing on a
// face the implementer's arm D did not build, and in particular over the three
// declaration objects that come out as a `ref_var` (a class TYPEDEF compiled
// late, a builtin `std::` handle, a hidden-vlog type), which `refVarLocalNoBind5`
// governs and which the window flips in EVERY home, class or not.
package q144c;
  typedef class FWDC;
  class BC;
    extern static function void si(input int a);
    extern static function void sq(input int a[$]);
    extern static function void sh(input FWDC a);
    extern static function void ss(input string a);
  endclass
  function void BC::si(input int a); endfunction
  function void BC::sq(input int a[$]); endfunction
  function void BC::sh(input FWDC a); endfunction
  function void BC::ss(input string a); endfunction
  class FWDC; int z; endclass
  typedef FWDC TDC;                       // typedef'd class
  class GENC #(type T = int); T g; endclass
  typedef GENC#(int) SPEC;                // parameterized specialization

  // c01..c06 FACES, function TOP, in-body class method, statement position
  class C01; int w; function void m(); int      v; BC::si(v);   w=1; endfunction endclass
  class C02; int w; function void m(); int      v[$]; BC::sq(v); w=2; endfunction endclass
  class C03; int w; function void m(); string   v; BC::ss(v);   w=3; endfunction endclass
  class C04; int w; function void m(); FWDC     v; BC::sh(v);   w=4; endfunction endclass
  class C05; int w; function void m(); TDC      v; BC::sh(v);   w=5; endfunction endclass
  class C06; int w; function void m(); SPEC     v; BC::si(v.g); w=6; endfunction endclass
  // c07 a BUILTIN std:: handle local -> a ref_var declaration object
  class C07; int w; function void m(); semaphore v; BC::si(w); w=7; endfunction endclass
  class C08; int w; function void m(); process   v; BC::si(w); w=8; endfunction endclass
  // c09 DECLARED AFTER STATEMENTS (inside a begin, the only legal spelling)
  class C09; int w; function void m(); w=9; begin int v; BC::si(v); end endfunction endclass
  // c10 inside an explicit begin-end at the top
  class C10; int w; function void m(); begin int v; BC::si(v); end w=10; endfunction endclass
  // c11 inside a FORK arm
  class C11; int w; task t(); fork begin int v; BC::si(v); end join_none w=11; endtask endclass
  // c12 in a TASK
  class C12; int w; task t(); int v; BC::si(v); w=12; endtask endclass
  // c13 in a VOID function
  class C13; int w; function void m(); int v; BC::si(v); w=13; endfunction endclass
  // c14 in a STATIC method
  class C14; static int w; static function void m(); int v; BC::si(v); w=14; endfunction endclass
  // c15 in an OUT-OF-BODY method
  class C15; int w; extern function void m(); endclass
  function void C15::m(); int v; BC::si(v); w=15; endfunction
  // c16 in a qualifier+lifetime stub (§ 141 must-stay)
  class C16; int w; static function automatic void m(); int v; BC::si(v); endfunction endclass
  // c17 WITH an initializer / c18 without, same method
  class C17; int w; function void m(); int v = 7; int u; BC::si(v); BC::si(u); w=17; endfunction endclass
  // c19 a STATIC local of an ordinary method
  class C19; int w; function void m(); static int v = 0; BC::si(v); w=19; endfunction endclass
  // c20 an AUTOMATIC local
  class C20; int w; function automatic void m(); automatic int v = 0; BC::si(v); w=20; endfunction endclass
  // c21 TWO locals in ONE declaration
  class C21; int w; function void m(); int v, u; BC::si(v); BC::si(u); w=21; endfunction endclass
  // c22 THREE instances of the same shape in one body
  class C22; int w; function void m(); int v1; int v2; int v3; BC::si(v1); BC::si(v2); BC::si(v3); w=22; endfunction endclass
  // c23 the receiver-less CONTROL for c01
  function automatic void barec(input int a); endfunction
  class C23; int w; function void m(); int v; barec(v); w=23; endfunction endclass
  // c24 a PACKAGE FREE function whose local is a ref_var face
  function automatic void pfc24(); TDC v; BC::sh(v); endfunction
  function automatic void pfc25(); semaphore v; BC::si(1); endfunction
endpackage

// c26..c28 the ref_var faces in NON-class homes, where the window now opens
// unconditionally.
module m144c;
  import q144c::*;
  int w;
  function automatic void mf26(); TDC v; BC::sh(v); endfunction
  task automatic mt27(); semaphore v; BC::si(w); endtask
  initial begin
    TDC v28;
    BC::sh(v28);
  end
endmodule

// r10v144 (VERIFIER) arm B — § ctorFirstBodyItemIsUnlistedNoBind144 taken apart.
// The recorder keys on the SLANG STATEMENT LIST's elements; Surelog eats the
// first GRAMMAR element.  Every cell below is a place those two counts could
// disagree, plus the § 71 / § 141 / § 46 must-stay controls in the same file.
package q144b;
  typedef class FWD144B;
  class B144B;
    extern static function void si(input int a);
    extern static function void sq(input int a[$]);
    extern static function void sd(input int a[]);
    extern static function void sa(input int a[string]);
    extern static function void sx(input int a[3]);
    extern static function void ss(input string a);
    extern static function void sh(input FWD144B a);
  endclass
  function void B144B::si(input int a); endfunction
  function void B144B::sq(input int a[$]); endfunction
  function void B144B::sd(input int a[]); endfunction
  function void B144B::sa(input int a[string]); endfunction
  function void B144B::sx(input int a[3]); endfunction
  function void B144B::ss(input string a); endfunction
  function void B144B::sh(input FWD144B a); endfunction
  class FWD144B; int z; endclass
  typedef FWD144B TDF144B;
  class GEN144B #(type T = int); T g; endclass
  typedef enum {E0, E1} en144b;
  typedef struct packed { int a; } st144b;

  // b01 TWO LOCALS IN ONE DECLARATION as the first body element.
  // Surelog's grammar has ONE block_item_declaration here; slang's statement
  // list has TWO.  If the recorder is element-keyed, only `b01a` is silenced.
  class B01; int w; function new(); int b01a, b01b; B144B::si(b01a); B144B::si(b01b); w = 1; endfunction endclass
  // b02 first element a declaration, SECOND ALSO a declaration (g09's shape)
  class B02; int w; function new(); int b02a; int b02b; B144B::si(b02a); B144B::si(b02b); w = 2; endfunction endclass
  // b03 first element `super.new()`, then a declaration -> the decl SURVIVES
  class B03base; function new(); endfunction endclass
  class B03 extends B03base; int w; function new(); super.new(); begin end w = 3; endfunction endclass
  class B03b extends B03base; int w; function new(); super.new(); begin int b03x; B144B::si(b03x); end w = 3; endfunction endclass
  // b04 first element an ASSIGNMENT, then a declaration -> the decl SURVIVES
  class B04; int w; function new(); w = 4; begin int b04x; B144B::si(b04x); end endfunction endclass
  // b05 STATIC local as the first body element
  class B05; int w; function new(); static int b05x = 0; B144B::si(b05x); w = 5; endfunction endclass
  // b06 AUTOMATIC local as the first body element
  class B06; int w; function new(); automatic int b06x = 0; B144B::si(b06x); w = 6; endfunction endclass
  // b07..b13 FACES as the first body element of a no-arg constructor
  class B07; int w; function new(); int b07[$];       B144B::sq(b07); w = 7;  endfunction endclass
  class B08; int w; function new(); int b08[];        B144B::sd(b08); w = 8;  endfunction endclass
  class B09; int w; function new(); int b09[string];  B144B::sa(b09); w = 9;  endfunction endclass
  class B10; int w; function new(); int b10[3];       B144B::sx(b10); w = 10; endfunction endclass
  class B11; int w; function new(); string b11;       B144B::ss(b11); w = 11; endfunction endclass
  class B12; int w; function new(); FWD144B b12;      B144B::sh(b12); w = 12; endfunction endclass
  class B13; int w; function new(); TDF144B b13;      B144B::sh(b13); w = 13; endfunction endclass
  // b14 parameterized specialization handle as first body element
  class B14; int w; function new(); GEN144B#(int) b14; B144B::si(b14.g); w = 14; endfunction endclass
  // b15 enum, b16 packed struct
  class B15; int w; function new(); en144b b15;       B144B::si(int'(b15)); w = 15; endfunction endclass
  class B16; int w; function new(); st144b b16;       B144B::si(b16.a); w = 16; endfunction endclass
  // b17 first body element declared INSIDE an explicit begin-end
  class B17; int w; function new(); begin int b17x; B144B::si(b17x); end w = 17; endfunction endclass
  // b18 a ctor WITH a port list (nothing is eaten) — MUST BIND
  class B18; int w; function new(int a); int b18x; B144B::si(b18x); w = a; endfunction endclass
  // b19 the eaten local read as an INC/DEC operand (§ incDecOperandBind21 overrides)
  class B19; int w; function new(); int b19x; b19x++; B144B::si(b19x); w = 19; endfunction endclass
  // b20 the eaten local read in an IF CONDITION (§ 64's window)
  class B20; int w; function new(); int b20x; if (b20x == 0) w = 20; B144B::si(b20x); endfunction endclass
  // b21 the eaten local read on an ASSIGNMENT RHS
  class B21; int w; function new(); int b21x; w = b21x; B144B::si(b21x); endfunction endclass
  // b22 OUT-OF-BODY constructor, first-element declaration
  class B22; int w; extern function new(); endclass
  function B22::new(); int b22x; B144B::si(b22x); w = 22; endfunction
  // b23 ordinary METHOD twin (must bind everywhere)
  class B23; int w; function void m(); int b23x; B144B::si(b23x); w = 23; endfunction endclass
  // b24 the eaten local passed to a RECEIVER-LESS call
  function automatic void bare144b(input int a); endfunction
  class B24; int w; function new(); int b24x; bare144b(b24x); w = 24; endfunction endclass
  // b25 the eaten local's own INITIALIZER reads a second eaten local
  class B25; int w; function new(); int b25a = 3, b25b = b25a; B144B::si(b25b); w = 25; endfunction endclass
  // b26 § 71 must-stay: a constructor whose body locals golden lists NOWHERE
  class B26; int w; function new(); int b26x; endfunction endclass
  // b27 § 141 must-stay: a qualifier+lifetime stub that lists NO body locals
  class B27; int w; static function automatic void qs(); int b27x; endfunction endclass
  // b28 a DERIVED class's ctor calling super.new WITH args, decl after
  class B28base; int q; function new(int a); q = a; endfunction endclass
  class B28 extends B28base; int w; function new(); super.new(1); begin int b28x; B144B::si(b28x); end w = 28; endfunction endclass
endpackage

// b29..b31 the same first-element rule in NON-package homes.
module m144b;
  import q144b::*;
  class M29; int w; function new(); int m29x; B144B::si(m29x); w = 29; endfunction endclass
endmodule
interface i144b;
  import q144b::*;
  class I30; int w; function new(); int i30x; B144B::si(i30x); w = 30; endfunction endclass
endinterface
import q144b::*;
class U31; int w; function new(); int u31x; B144B::si(u31x); w = 31; endfunction endclass

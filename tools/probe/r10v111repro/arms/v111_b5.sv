// r10v111 ARM B5 — WHERE the call sits.  A package PARAMETER initializer, a
// localparam, an operation, a ternary, a concatenation, a system-function
// argument, and a package that declares a FREE function whose short name
// collides with the method's.
package v111b5p;
  class Sh5;
    extern static function int mk5();
    extern static function int mk5b();
  endclass
  function int Sh5::mk5();
    mk5 = 5;
  endfunction
  function int Sh5::mk5b();
    mk5b = 6;
  endfunction
  parameter  int P5 = Sh5::mk5();
  localparam int L5 = Sh5::mk5() + Sh5::mk5b();
  int t5 = (Sh5::mk5() > 2) ? Sh5::mk5b() : 0;
  int c5 = {Sh5::mk5()};
  int a5 = Sh5::mk5b() + 1;
  int s5 = $signed(Sh5::mk5());
endpackage

package v111b5w;
  import v111b5p::*;
  int w5 = Sh5::mk5();
endpackage

package v111b5s;
  import v111b5p::*;
  function int mk5();
    return 99;
  endfunction
  int q5 = Sh5::mk5();
  int r5 = mk5();
endpackage

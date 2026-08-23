// r10v111 ARM B7 — NAME COLLISION AND CONSTRUCTORS.  Two classes in ONE package
// whose out-of-body static methods share a short name (`shared7`), a typedef
// ALIAS used as the scope-resolution head, and an out-of-body CONSTRUCTOR
// reached through a package-scope class-handle variable initialised with
// `new()`.  A by-name rebind that keyed on the SHORT method name, or that took
// the wrong entry when two exist, would show here.
package v111b7p;
  class Alpha7;
    extern static function int shared7();
  endclass
  class Beta7;
    extern static function int shared7();
  endclass
  typedef Alpha7 AliasA7;
  class Ctor7;
    int v7;
    extern function new(int a);
  endclass
  function int Alpha7::shared7();
    shared7 = 71;
  endfunction
  function int Beta7::shared7();
    shared7 = 72;
  endfunction
  function Ctor7::new(int a);
    v7 = a;
  endfunction
  int a7 = Alpha7::shared7();
  int b7 = Beta7::shared7();
  int c7 = AliasA7::shared7();
  Ctor7 h7 = new(3);
endpackage

package v111b7w;
  import v111b7p::*;
  int wb7 = Beta7::shared7();
endpackage

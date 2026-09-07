// r10uvm189 arm B — SCOPES.  The SAME class-name index at six declaration
// scopes: package variable, class property, out-of-body method local, a
// NESTED-begin local inside that body, an out-of-body TASK local, a free
// package function local, and a module variable — home listing and
// wildcard-import clone listing, both views.
package Lintel189;
  class Corbel189;
    int rungB189;
  endclass
  bit pkgVarB189[Corbel189];
  class Astragal189;
    bit propB189[Corbel189];
    extern function void chiselB189();
    extern task planeB189();
  endclass
  function void Astragal189::chiselB189();
    bit locB189[Corbel189];
    locB189[null] = 1'b1;
    begin : nestB189
      bit nestedB189[Corbel189];
      nestedB189[null] = 1'b1;
    end
  endfunction
  task Astragal189::planeB189();
    bit taskLocB189[Corbel189];
    taskLocB189[null] = 1'b1;
  endtask
  function void freeScopeB189();
    bit freeLocB189[Corbel189];
    freeLocB189[null] = 1'b1;
  endfunction
endpackage

package Soffit189;
  import Lintel189::*;
  function void useScopeB189();
    Astragal189 aB189;
    aB189 = new();
    aB189.chiselB189();
    freeScopeB189();
  endfunction
endpackage

module topLintel189;
  import Soffit189::*;
  bit modVarB189[Lintel189::Corbel189];
  initial useScopeB189();
endmodule

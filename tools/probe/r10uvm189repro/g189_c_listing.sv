// r10uvm189 arm C — THE LISTING AXIS.  One home package, one EXPLICIT-import
// package (`import P::fn;`) and one WILDCARD-import package, so the law's gate
// (`pkgImportCloneEmit`) is separated from the mere presence of an import, and
// a package that is never imported at all is the negative.
package Newel189;
  class Baluster189;
    int stepC189;
  endclass
  class Volute189;
    extern function void turnC189();
  endclass
  function void Volute189::turnC189();
    bit turnClsC189[Baluster189];
    bit turnStrC189[string];
    turnClsC189[null] = 1'b1;
    turnStrC189["q"] = 1'b1;
  endfunction
  function void freeTurnC189();
    bit freeClsC189[Baluster189];
    freeClsC189[null] = 1'b1;
  endfunction
endpackage

package Quoin189;
  class Fillet189;
    int beadC189;
  endclass
  function void neverImportedC189();
    bit loneClsC189[Fillet189];
    loneClsC189[null] = 1'b1;
  endfunction
endpackage

package Riser189;
  import Newel189::freeTurnC189;
  function void useRiserC189();
    freeTurnC189();
  endfunction
endpackage

package Tread189;
  import Newel189::*;
  function void useTreadC189();
    Volute189 vC189;
    vC189 = new();
    vC189.turnC189();
    freeTurnC189();
  endfunction
endpackage

module topNewel189;
  import Tread189::*;
  import Riser189::*;
  initial begin
    useTreadC189();
    useRiserC189();
  end
endmodule

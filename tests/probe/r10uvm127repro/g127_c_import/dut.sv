// r10uvm127 grid C — WILDCARD-IMPORT CLONES.  `Ravelin` declares the bodies,
// `Sundial` only imports them: Surelog's CompileHelper::importPackage
// clone_trees the ELABORATED listing into BOTH views of the importer, so both
// of the importer's copies carry the stamp while the HOME package's own
// unelaborated listing stays bare.  Callees are DPI-C imports so the calls
// survive.  MEASUREMENT ONLY.
package Ravelin;
  import "DPI-C" function int glazeCat (string frontish, string backish);
  import "DPI-C" function int tundraAdd(int alpha7, byte beta3);

  function automatic int quarryTop(string frontish, string backish);
    return glazeCat(frontish, backish);
  endfunction

  function automatic int lattermathTop(int alpha7, byte beta3);
    return tundraAdd(alpha7, beta3);
  endfunction

  class Palisade;
    extern function int oobWrap(string frontish, string backish);
  endclass

  function int Palisade::oobWrap(string frontish, string backish);
    return glazeCat(frontish, backish);
  endfunction
endpackage

package Sundial;
  import Ravelin::*;
  int kettle = 4;
endpackage

module Sundial_top;
  import Sundial::*;
  import Ravelin::*;
  int got;
  int num;
  initial begin
    got = quarryTop("l", "r");
    num = lattermathTop(3, 8'h04);
  end
endmodule

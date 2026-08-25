// r10v135 (VERIFIER) ARM b12 — the hoisted name collides with a top-level PORT,
// with a top-level FUNCTION, with a TYPEDEF in the top, and with a GENERATE
// BLOCK label.  And the SAME class name is an index in TWO packages.
package pkgOneAlfa12;
  class shareBravoCls12; int v; endclass
  class portCharlieCls12; int v; endclass
  class fnDeltaCls12;    int v; endclass
  class tdEchoCls12;     int v; endclass
  class ownFoxtrot12;
    extern function void oobGolf12();
  endclass
  function void ownFoxtrot12::oobGolf12();
    bit z01Share12 [shareBravoCls12];
    bit z02Port12  [portCharlieCls12];
    bit z03Fn12    [fnDeltaCls12];
    bit z04Td12    [tdEchoCls12];
    z01Share12.delete(); z02Port12.delete(); z03Fn12.delete(); z04Td12.delete();
  endfunction
endpackage

package pkgTwoHotel12;
  import pkgOneAlfa12::shareBravoCls12;
  class ownIndia12;
    extern function void oobJuliett12();
  endclass
  function void ownIndia12::oobJuliett12();
    bit z05ShareAgain12 [shareBravoCls12];   // the SAME class, a SECOND package
    z05ShareAgain12.delete();
  endfunction
endpackage

module topCollKilo12 (input wire portCharlieCls12);   // a PORT with that name
  import pkgOneAlfa12::*;
  import pkgTwoHotel12::*;
  typedef int tdEchoCls12;                            // a TYPEDEF with that name
  function int fnDeltaCls12();                        // a FUNCTION with that name
    return 7;
  endfunction
  ownFoxtrot12 oLima12;
  ownIndia12   oMike12;
  initial begin
    oLima12 = new(); oLima12.oobGolf12();
    oMike12 = new(); oMike12.oobJuliett12();
  end
endmodule

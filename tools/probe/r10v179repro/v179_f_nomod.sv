// r10v179 ADVERSARIAL ARM F — THE FACE WITH NO IMPORTING MODULE AT ALL.
// Every other arm gives Surelog a module to hoist the class body into, which
// is where § oobRefVarLocalHoistNet107's minted wire lives.  Here there is no
// module, so the ONLY listing is the package's, and the law must still hold.
// A second package IMPORTS the first, so the import-clone listing is measured
// too.  MEASUREMENT ONLY.
package pkg_uniform;

  class Chip;
    int lane;
  endclass

  class Rig;
    function int  scan(Chip c); return 0; endfunction
    function void load(Chip c); endfunction
  endclass

  class Panel #(type CELL = Chip);
    Rig rg;
    int total;
    extern function void f_face();
    extern function void f_stmt();
  endclass

  function void Panel::f_face();
    CELL slotv;
    if (rg.scan(slotv) == 0) total = 1;      // f01 no module anywhere
  endfunction

  function void Panel::f_stmt();
    CELL slotv;
    rg.load(slotv);                          // f02 statement twin
  endfunction

endpackage

package pkg_tango;
  import pkg_uniform::*;
  export pkg_uniform::*;
  int tango_tick;
endpackage

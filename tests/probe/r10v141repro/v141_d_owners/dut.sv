// r10uvm141 VERIFIER arm D -- OWNERS the implementer's grid did not reach:
// an INTERFACE-owned class, a PROGRAM-owned class, a class inside a MODULE
// GENERATE block, a $unit class, a DERIVED class overriding a base virtual,
// and a WILDCARD-IMPORT clone of a package class.
// One affected method per class so nothing collapses.

// ---- $unit-scope class (compilation unit) -------------------------------
class du_unit;
  local function automatic int fu(int a);
    int ru = a + 1;
    int ru0 = a - 1;
    return ru + ru0;
  endfunction
endclass

package p141d;
  class dp_base;
    virtual function automatic int vb(int a);   // affected, base
      int rb = a;
      return rb;
    endfunction
    function int plain(int a);                  // control, neither feature
      int pb = a;
      return pb;
    endfunction
  endclass
  class dp_der extends dp_base;
    virtual function automatic int vb(int a);   // affected, OVERRIDE
      int rd = a * 2;
      return rd;
    endfunction
  endclass
  class dp_imp;
    protected function automatic int fi(int a); // affected, wildcard-imported
      int ri = a;
      int ri0 = a;
      return ri + ri0;
    endfunction
  endclass
endpackage

package p141d2;
  import p141d::*;                              // wildcard-import CLONE face
  function automatic int use_it();
    dp_imp h;
    h = new();
    return 0;
  endfunction
endpackage

interface if141d;
  class di_iface;
    local function automatic int fif(int a);    // affected, INTERFACE owner
      int rif = a;
      return rif;
    endfunction
  endclass
endinterface

program pg141d;
  class dg_prog;
    static function automatic int fpg(int a);   // affected, PROGRAM owner
      int rpg = a;
      return rpg;
    endfunction
  endclass
  initial begin
    dg_prog hp;
    hp = new();
  end
endprogram

module t141d;
  if141d ifi();
  genvar gi;
  for (gi = 0; gi < 2; gi++) begin : gblk
    class dgen;                                 // affected, GENERATE-block owner
      protected function automatic int fgen(int a);
        int rg = a;
        return rg;
      endfunction
    endclass
  end
  initial begin
    du_unit hu; p141d::dp_base hb; p141d::dp_der hd; p141d::dp_imp hi;
    hu = new(); hb = new(); hd = new(); hi = new();
  end
endmodule

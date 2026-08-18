// r10vbuvm16 arm v2 — THE HOME GUARD.  Every non-package home a subroutine can
// have: $unit (CompilationUnit), interface, program, module fn/task/initial/
// final, a class declared inside each of those, and a generate block.
// The law admits ONLY Package / CompilationUnit; every other home must be
// BYTE-IDENTICAL between pristine and patched.

int uvar2;                                     // $unit variable
function automatic void ufn2(int ufm);         // $unit function
  int ufl; int uarr[];
  uarr = new[ufl];                             // v2_unitfn_local
  uarr = new[ufm];                             // v2_unitfn_formal
  uarr = new[uvar2];                           // v2_unitfn_unitvar
endfunction

class ucls2;                                   // $unit-scope class
  int uda[];
  extern function void uob(int uom);
endclass
function void ucls2::uob(int uom);
  int uol;
  uda = new[uol + uom];                        // v2_unitclass_oob
endfunction

interface vif2;
  int ivar2;
  function automatic void ifn2(int ifm);
    int ifl; int iarr[];
    iarr = new[ifl];                           // v2_ifacefn_local
    iarr = new[ifm];                           // v2_ifacefn_formal
  endfunction
  class icls2;
    int ida[];
    extern function void iob(int iom);
  endclass
  function void icls2::iob(int iom);
    int iol;
    ida = new[iol + iom];                      // v2_ifaceclass_oob
  endfunction
endinterface

program vpg2;
  int pvar2;
  function automatic void pfn2(int pfm);
    int pfl; int parr[];
    parr = new[pfl];                           // v2_progfn_local
    parr = new[pfm];                           // v2_progfn_formal
  endfunction
  class pcls2;
    int pda[];
    extern function void pob(int pom);
  endclass
  function void pcls2::pob(int pom);
    int pol;
    pda = new[pol + pom];                      // v2_progclass_oob
  endfunction
endprogram

module top2;
  int mvar2;
  int marr2[];
  function automatic void mfn2(int mfm);
    int mfl; int farr[];
    farr = new[mfl];                           // v2_modfn_local
    farr = new[mfm];                           // v2_modfn_formal
    farr = new[mvar2];                         // v2_modfn_modvar
  endfunction
  task automatic mtk2(int tkm);
    int tkl; int tarr[];
    tarr = new[tkl + tkm];                     // v2_modtask
  endtask
  class mcls2;                                 // class declared INSIDE a module
    int mda[];
    extern function void mob(int mom);
  endclass
  function void mcls2::mob(int mom);
    int mol;
    mda = new[mol + mom];                      // v2_modclass_oob
  endfunction
  initial begin
    int iloc2;
    marr2 = new[iloc2];                        // v2_mod_initial
  end
  final begin
    int floc2;
    marr2 = new[floc2];                        // v2_mod_final
  end
  if (1) begin : gblk2
    int gvar2;
    int garr2[];
    function automatic void gfn2(int gfm);
      int gfl;
      garr2 = new[gfl + gfm];                  // v2_genblk_fn
    endfunction
  end
  ucls2 uh2;
  initial begin
    uh2 = new();
    ufn2(3);
    uh2.uob(4);
  end
endmodule

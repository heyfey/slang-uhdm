// r10uvm142 arm B — THE CLASS-HOME axis, against the USE-SITE's home.
// Every cell is a class-handle local under BOTH productions; what varies is
// where the CLASS lives (this package / another package / $unit / a module /
// nested in the enclosing class).  This is the arm that decides whether
// `vpiInstance` names the CLASS's home package or the USE SITE's.
package pb1142;
  class Kb1142;
    int f;
  endclass
  typedef Kb1142 tb1142;
endpackage

class Ub142;
  int f;
endclass

package pb2142;
  import pb1142::*;
  class Kb2142;
    int f;
  endclass
  class Hb142;
    class Nb142;                 // a class NESTED in the enclosing class
      int f;
    endclass
    extern function void btf;
    extern function void bbl();
    function void ibtf;
      Kb2142          ib_same;
      Kb1142          ib_othimp;
      pb1142::Kb1142  ib_othscoped;
      Nb142           ib_nested;
      tb1142          ib_othtd;
    endfunction
    function void ibbl();
      Kb2142          ibb_same;
      Kb1142          ibb_othimp;
      pb1142::Kb1142  ibb_othscoped;
      Nb142           ibb_nested;
      tb1142          ibb_othtd;
    endfunction
  endclass
  function void Hb142::btf;
    Kb2142          oo_same;
    Kb1142          oo_othimp;
    pb1142::Kb1142  oo_othscoped;
    Nb142           oo_nested;
    tb1142          oo_othtd;
  endfunction
  function void Hb142::bbl();
    Kb2142          oob_same;
    Kb1142          oob_othimp;
    pb1142::Kb1142  oob_othscoped;
    Nb142           oob_nested;
    tb1142          oob_othtd;
  endfunction
  function void bpftf;
    Kb2142          pf_same;
    Kb1142          pf_othimp;
    pb1142::Kb1142  pf_othscoped;
    tb1142          pf_othtd;
  endfunction
  function void bpfbl();
    Kb2142          pfb_same;
    Kb1142          pfb_othimp;
    pb1142::Kb1142  pfb_othscoped;
    tb1142          pfb_othtd;
  endfunction
  // The non-local controls: a package variable and a class property.
  Kb2142         bpkgvar_same;
  pb1142::Kb1142 bpkgvar_oth;
endpackage

module mb142;
  import pb2142::*;
  class Mb142;
    int f;
  endclass
  class Mhb142;
    extern function void mbtf;
    extern function void mbbl();
  endclass
  function void Mhb142::mbtf;
    Mb142           mo_samemod;
    pb1142::Kb1142  mo_pkg;
    Ub142           mo_unit;
  endfunction
  function void Mhb142::mbbl();
    Mb142           mob_samemod;
    pb1142::Kb1142  mob_pkg;
    Ub142           mob_unit;
  endfunction
  function void mbfntf;
    Mb142           mf_samemod;
    pb1142::Kb1142  mf_pkg;
    Ub142           mf_unit;
  endfunction
  function void mbfnbl();
    Mb142           mfb_samemod;
    pb1142::Kb1142  mfb_pkg;
    Ub142           mfb_unit;
  endfunction
  Mb142 mbvar142;
endmodule

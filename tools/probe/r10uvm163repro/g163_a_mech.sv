// r10uvm163 / arm A — THE MECHANISM.  Where does a class PROPERTY typed by a
// parameterized specialization keep its vpiParameter listing?
//
// r10uvm53's law § classPkgGenericSpecListing53 says "the generic class lives
// in a PACKAGE => no listing".  Its decisive cell a3/e2 ($unit class holding a
// PACKAGE generic) was spelled `r53::rgc53#(r53::rcfg53)` — a SCOPED name,
// which takes Surelog's paClass_scope arm and never reaches the probe site at
// all.  So the UNQUALIFIED foreign-home spelling — the Scoreboard corpus cell
// `uvm_analysis_imp #(int, my_scoreboard) m_imp;` — was NEVER MEASURED.
//
// The two axes crossed here:
//   S : the SPELLING            unqualified `G#(..)`  vs  scoped `pk::G#(..)`
//   H : the HOME RELATION       can Surelog's three getClassDefinition probes
//                               spell the generic's registry key from the
//                               DECLARING class's component name / its parent
//                               scope's name?
// LHS is ALWAYS golden(Surelog); RHS is always ours.  Every cell is a class
// PROPERTY and is named in the comment above it.

// ---------------------------------------------------------------- $unit types
class cfgUnit163;
  int qq;
endclass

class genUnit163 #(type TA = int, type TB = int);
  TA aa;
  TB bb;
endclass

// ------------------------------------------------------------- package ALPHA
package alpha163;
  class cfgAl163;
    int qq;
  endclass
  class genAl163 #(type TA = int, type TB = int);
    TA aa;
    TB bb;
  endclass

  // a1 : PACKAGE class, SAME-package generic, UNQUALIFIED   (a1/c1 control)
  class holdAl163;
    genAl163#(cfgAl163) a1_samepkg_unqual;
  endclass

  // a11 : a class NESTED in a PACKAGE class, SAME-package generic.  Surelog
  //       gives a nested ClassDefinition its OUTER class's CONTAINER as its
  //       parent scope (CompileClass.cpp:693), so probe 3 spells
  //       `alpha163::genAl163` here and should HIT.
  class outerAl163;
    class innerAl163;
      genAl163#(cfgAl163) a11_pkgnested_samepkg;
    endclass
    innerAl163 ih;
  endclass
endpackage

// ------------------------------------------------------------- package BETA
package beta163;
  import alpha163::*;
  class cfgBe163;
    int qq;
  endclass

  // a2 : PACKAGE class, OTHER package's generic, UNQUALIFIED (wildcard import)
  //      NEVER MEASURED BY r10uvm53.
  class holdBe163;
    genAl163#(cfgBe163) a2_crosspkg_unqual;
    // a3 : the SAME cross-package generic, SCOPED spelling
    alpha163::genAl163#(cfgBe163) a3_crosspkg_scoped;
  endclass

  // a12 : a class NESTED in a PACKAGE class, referencing ANOTHER package's
  //       generic UNQUALIFIED.  Both probes miss.
  class outerBe163;
    class innerBe163;
      genAl163#(cfgBe163) a12_pkgnested_crosspkg;
    endclass
    innerBe163 ih;
  endclass
endpackage

// ------------------------------------------------------------ $unit classes
import alpha163::*;

// a4 : $unit class, PACKAGE generic, UNQUALIFIED  <-- THE SCOREBOARD SHAPE
// a5 : $unit class, PACKAGE generic, SCOPED       (r10uvm53 a3/e2 replicated)
// a6 : $unit class, $unit generic, UNQUALIFIED    (r10uvm53 a2/d1 control)
class holdUnit163;
  genAl163#(cfgUnit163) a4_unitcls_pkggen_unqual;
  alpha163::genAl163#(cfgUnit163) a5_unitcls_pkggen_scoped;
  genUnit163#(cfgUnit163) a6_unitcls_unitgen_unqual;
endclass

// a7 : $unit class, PACKAGE generic, UNQUALIFIED, TWO written arguments where
//      the second names the DECLARING class itself — the exact Scoreboard text.
class holdSelf163;
  genAl163#(int, holdSelf163) a7_unitcls_selfarg;
endclass

// a13 : a class NESTED in a $unit class, PACKAGE generic, UNQUALIFIED.
class outerUnit163;
  class innerUnit163;
    genAl163#(cfgUnit163) a13_unitnested_pkggen;
  endclass
  innerUnit163 ih;
endclass

// ------------------------------------------------------------- module scope
module top163;
  // a8 : MODULE class, PACKAGE generic, UNQUALIFIED
  // a9 : MODULE class, $unit generic, UNQUALIFIED   (r10uvm53 a3/e5 control)
  class holdMod163;
    genAl163#(cfgUnit163) a8_modcls_pkggen_unqual;
    genUnit163#(cfgUnit163) a9_modcls_unitgen_unqual;
  endclass

  // a10 : a class NESTED in a class, referencing the OUTER class's package
  //       generic — probe 2 spells `<outer>::<name>`.
  class outerMod163;
    class innerMod163;
      genUnit163#(cfgUnit163) a10_nestedcls_unitgen;
    endclass
    innerMod163 ih;
  endclass

  holdMod163 hm;
  outerMod163 om;
  holdUnit163 hu;
  holdSelf163 hs;
  outerUnit163 ou;
  alpha163::outerAl163 oa;
  beta163::outerBe163 ob;
  alpha163::holdAl163 ha;
  beta163::holdBe163 hb;
endmodule

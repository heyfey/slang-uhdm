// r10oth8 arm a8 — the PACKAGE-TYPEDEF distinguisher, and the single most
// load-bearing arm of the pass.  a3/a4/a5/a7 all used $unit typedefs.  If
// Surelog resolves a typedef declared in a PACKAGE (which is how UVM spells
// every one of its element types) and then DOES compute signedness, the law is
// not "written vs typedef'd" at all and the whole model is refuted.  Both
// spellings are exercised: the wildcard-imported bare name and the explicit
// `pkg::name` qualification, because "wildcard vs qualified package use" is a
// distinguisher this campaign has been bitten by before (PLAYBOOK, technique 3).
package tp;
  typedef byte  pb_t;
  typedef int   pi_t;
  typedef bit [7:0] pu8_t;
endpackage

// The wildcard import lives at COMPILATION-UNIT scope: slang rejects
// `import` inside a class body outright (-Wpackage-import-in-class), so the
// bare-name cell has to be reached this way.  The class still sees `pb_t`.
import tp::*;

class kc;
  rand pb_t       k01_dyn_bare[];        // wildcard-imported typedef name
  rand tp::pb_t   k02_dyn_qual[];        // explicitly qualified
  rand tp::pi_t   k03_q_qual[$];
  rand tp::pu8_t  k04_dyn_qualu[];       // unsigned control
  rand byte       k05_dyn_written[];     // written-keyword control in the same class
endclass

module a8_top;
  import tp::*;
  pb_t       m01_dyn_bare[];
  tp::pb_t   m02_dyn_qual[];
  tp::pi_t   m03_q_qual[$];
  tp::pu8_t  m04_dyn_qualu[];
  byte       m05_dyn_written[];
  tp::pb_t   m06_fix_qual[4];            // the FIXED path, typedef'd
  byte       m07_fix_written[4];         // the FIXED path, written
  kc kh;
  initial kh = new();
endmodule

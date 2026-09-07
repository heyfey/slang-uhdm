// r10v202 arm 1 — TYPEDEF CHAINS, TWO TYPEDEFS OF ONE SPECIALISATION, and a
// PACKAGE-SCOPE `parameter type`.  The verifier's question: does
// § pkgClassTdImportCopyLocalUnsupported202 fire on constructs its own grid
// never showed it, and does golden agree?
//
//   * `specAliasV1` — a SECOND typedef of the SAME specialisation object
//     (arm A only had two typedefs of two DIFFERENT specialisations).
//   * `clsAliasV1`  — a typedef of a typedef of a PLAIN class handle.
//   * `tparV1`      — a PACKAGE-SCOPE `parameter type` bound to a class.  In
//     slang a type parameter is a TypeAliasType whose parent scope is the
//     PACKAGE, so `pkgClassTdLocalName202`'s two clauses are both TRUE for it
//     — this arm is what decides whether that is golden's reading.
//   * `intAliasV1`  — the same chain shape over an INT (the must-not-move
//     control from uvm170's family).
package quarryV1202;
  class PlainV1202;
    int aV1;
  endclass
  class GenV1202 #(type TV1 = int);
    TV1 vV1;
  endclass

  typedef GenV1202#(int) specV1202;        // a specialisation
  typedef specV1202      specAliasV1202;   // a SECOND typedef of the SAME specialisation
  typedef PlainV1202     clsV1202;         // a plain class handle
  typedef clsV1202       clsAliasV1202;    // a typedef OF a typedef of a class
  typedef int            intV1202;         // CONTROL
  typedef intV1202       intAliasV1202;    // CONTROL chain
  parameter type tparV1202 = PlainV1202;   // package-scope TYPE PARAMETER

  class AditV1202;
    extern function void winzeV1202();
  endclass

  function void AditV1202::winzeV1202();
    specV1202      tfSpecV1;
    specAliasV1202 tfSpecAliasV1;
    clsV1202       tfClsV1;
    clsAliasV1202  tfClsAliasV1;
    intV1202       tfIntV1;
    intAliasV1202  tfIntAliasV1;
    tparV1202      tfTparV1;
    begin
      specV1202      blkSpecV1;
      specAliasV1202 blkSpecAliasV1;
      clsAliasV1202  blkClsAliasV1;
      intAliasV1202  blkIntAliasV1;
      tparV1202      blkTparV1;
      blkSpecV1      = null;
      blkSpecAliasV1 = null;
      blkClsAliasV1  = null;
      blkIntAliasV1  = 0;
      blkTparV1      = null;
    end
    tfSpecV1      = null;
    tfSpecAliasV1 = null;
    tfClsV1       = null;
    tfClsAliasV1  = null;
    tfIntV1       = 0;
    tfIntAliasV1  = 0;
    tfTparV1      = null;
  endfunction
endpackage

package sluiceV1202;                       // THE WILDCARD IMPORTER — the clone
  import quarryV1202::*;
  class FlumeV1202;
    function void raceV1202();
      AditV1202 gateV1;
      gateV1 = null;
    endfunction
  endclass
endpackage

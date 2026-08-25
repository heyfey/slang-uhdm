// r10v135 (VERIFIER) ARM b11 — NON-SUBROUTINE HOMES, each with its OWN class
// name so no home can be confirmed by another's answer.  Does golden mint the
// importing module's implicit wire for a PACKAGE variable, a $unit variable, a
// MODULE variable and a module PARAMETER default?
class unitOwnAlfa11;   int v; endclass

package pkgHomeBravo11;
  class pkgOwnCharlie11; int v; endclass
  bit y01PkgVar11 [pkgOwnCharlie11];     // a PACKAGE-scope variable
endpackage

bit y02UnitVar11 [unitOwnAlfa11];        // a $unit-scope variable

module topHomeDelta11;
  import pkgHomeBravo11::*;
  class modOwnEcho11; int v; endclass
  bit y03ModVar11 [modOwnEcho11];        // a MODULE variable, module class
  bit y04ModUnit11 [unitOwnAlfa11];      // a MODULE variable, $unit class
  bit y05ModPkg11 [pkgOwnCharlie11];     // a MODULE variable, package class
  initial begin
    y03ModVar11.delete();
    y04ModUnit11.delete();
    y05ModPkg11.delete();
  end
endmodule

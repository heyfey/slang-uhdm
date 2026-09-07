// r10uvm202 arm B — THE SPELLING AND THE SHAPE.
// What the WRITTEN type looks like, with a control beside every cell in the
// same cloned body: the bare identifier (the law), the SCOPED spelling, a
// a typedef imported from a THIRD package, the ARRAY spelling
// (the fence), and a class handle written WITHOUT a typedef (the control that
// says the law is about the TYPEDEF and not about class handles at large).
package third202;
  class Ore202;
    int assay202;
  endclass
  typedef Ore202 thirdCls202;                    // a THIRD package's class typedef
endpackage

package quarry202b;
  import third202::*;
  class Plain202b;
    int lode202b;
  endclass
  class Vein202b #(type T202b = int);
    T202b ore202b;
  endclass
  typedef Vein202b#(int) pkgSpec202b;            // the LAW's type
  typedef Plain202b      pkgCls202b;
  typedef int            pkgInt202b;             // CONTROL

  class Adit202b;
    extern function void winze202b();
  endclass

  function void Adit202b::winze202b();
    pkgSpec202b            bBare202b;            // the LAW: bare spelling
    quarry202b::pkgSpec202b bScoped202b;         // the SCOPED spelling
    third202::thirdCls202  bThirdQ202b;          // a THIRD package, qualified
    thirdCls202            bThirdB202b;          // a THIRD package, bare
    pkgSpec202b            bArr202b[4];          // THE ARRAY FENCE
    Plain202b              bNoTd202b;            // CONTROL: no typedef at all
    pkgInt202b             bInt202b;             // CONTROL: plain package typedef
    begin
      pkgSpec202b            kBare202b;
      quarry202b::pkgSpec202b kScoped202b;
      thirdCls202            kThirdB202b;
      pkgSpec202b            kArr202b[4];
      Plain202b              kNoTd202b;
      pkgInt202b             kInt202b;
      kBare202b = null;
      kScoped202b = null;
      kThirdB202b = null;
      kArr202b[0] = null;
      kNoTd202b = null;
      kInt202b = 0;
    end
    bBare202b = null;
    bScoped202b = null;
    bThirdQ202b = null;
    bThirdB202b = null;
    bArr202b[0] = null;
    bNoTd202b = null;
    bInt202b = 0;
  endfunction
endpackage

package sluice202b;
  import quarry202b::*;
  class Flume202b;
    function void race202b();
      Adit202b gate202b;
      gate202b = null;
    endfunction
  endclass
endpackage

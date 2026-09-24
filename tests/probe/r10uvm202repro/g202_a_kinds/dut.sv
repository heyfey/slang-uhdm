// r10uvm202 arm A — WHICH PACKAGE-SCOPE TYPEDEF KINDS DEGRADE IN A CLONE.
// One real Surelog golden decides, in ONE file and BOTH views, whether the
// wildcard-import clone's body local degrades to an `unsupported_typespec` for
// a PACKAGE-scope typedef of a PARAMETERISED CLASS SPECIALISATION, and whether
// the plain package typedefs beside it (struct / enum / vector / int / PLAIN
// class handle) stay resolved — the uvm170 must-not-move family and
// § 198's own `tfPkg198` control, restated as this law's fence.
//
// Every cell has a control declared beside it in the SAME cloned body.
package quarry202;
  class Plain202;
    int lode202;
  endclass
  class Vein202 #(type T202 = int, type U202 = int);
    T202 ore202;
    function void assay202();
    endfunction
  endclass

  typedef struct { int shaft202; string drift202; } pkgSt202;  // CONTROL package STRUCT
  typedef enum { EAST202, WEST202 } pkgEn202;                  // CONTROL package ENUM
  typedef logic [7:0] pkgVec202;                               // CONTROL package VECTOR
  typedef int pkgInt202;                                       // CONTROL package INT
  typedef Plain202 pkgCls202;                                  // package PLAIN class handle
  typedef Vein202#(int, string) pkgSpec202;                    // THE LAW: package SPECIALISATION
  typedef Vein202#(string, int) pkgSpecB202;                   // a SECOND specialisation, SAME generic

  class Adit202;
    extern function void winze202();
    function void inbody202();          // NEVER cloned (in-body method)
      pkgSpec202 inbodySpec202;
      inbodySpec202 = null;
    endfunction
  endclass

  function void Adit202::winze202();
    pkgSpec202  tfSpec202;      // tf-item local, package SPECIALISATION typedef
    pkgSpecB202 tfSpecB202;     // tf-item local, the second specialisation
    pkgCls202   tfCls202;       // tf-item local, package PLAIN class handle typedef
    pkgSt202    tfSt202;        // CONTROL
    pkgEn202    tfEn202;        // CONTROL
    pkgVec202   tfVec202;       // CONTROL
    pkgInt202   tfInt202;       // CONTROL
    begin
      pkgSpec202  blkSpec202;   // BLOCK-item local — the CORPUS HEAD's site
      pkgSpecB202 blkSpecB202;
      pkgCls202   blkCls202;
      pkgSt202    blkSt202;     // CONTROL
      pkgEn202    blkEn202;     // CONTROL
      pkgVec202   blkVec202;    // CONTROL
      pkgInt202   blkInt202;    // CONTROL
      blkSpec202 = null;
      blkSpecB202 = null;
      blkCls202 = null;
      blkSt202.shaft202 = 0;
      blkEn202 = EAST202;
      blkVec202 = 8'h0;
      blkInt202 = 0;
    end
    tfSpec202 = null;
    tfSpecB202 = null;
    tfCls202 = null;
    tfSt202.shaft202 = 0;
    tfEn202 = WEST202;
    tfVec202 = 8'h0;
    tfInt202 = 0;
  endfunction
endpackage

package sluice202;              // THE WILDCARD IMPORTER — the clone lives here
  import quarry202::*;
  class Flume202;
    function void race202();
      Adit202 gate202;
      gate202 = null;
    endfunction
  endclass
endpackage

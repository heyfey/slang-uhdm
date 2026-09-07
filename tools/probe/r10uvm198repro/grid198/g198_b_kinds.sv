// r10uvm198 arm B — DOES THE TYPEDEF'S KIND MATTER?
// Arm A already showed a class-scope STRUCT and a class-scope INT degrade
// alike in the clone; this arm reads every remaining kind off one golden, plus
// the two neighbouring laws that MUST NOT MOVE:
//   * the FORMAL cell — § classScopedTdImportCopyUnsupported36, already
//     modelled: it must read the same on both binaries;
//   * the SCOPED spelling `Kiln198::potSt198` — § classScopedTdDeclTsUnsupported11,
//     which degrades in EVERY view, home included.
package kiln198;
  typedef struct { int glaze198; } pkgSt198;
  class Kiln198;
    typedef struct { int slip198; string bisque198; } potSt198;
    typedef enum { GREEN198, FIRED198 } kilnEn198;
    typedef union { int muffle198; bit [31:0] saggar198; } potUn198;
    typedef string potStr198;
    typedef bit [7:0] potVec198;
    typedef int potInt198;
    typedef pkgSt198 potAlias198;          // class typedef ALIASING a package one
    typedef Kiln198 potSelf198;            // class typedef of a CLASS handle
    extern function void throw198(potSt198 formalPot198, pkgSt198 formalPkg198);
  endclass
  function void Kiln198::throw198(potSt198 formalPot198, pkgSt198 formalPkg198);
    begin
      potSt198        kSt198;
      kilnEn198       kEn198;
      potUn198        kUn198;
      potStr198       kStr198;
      potVec198       kVec198;
      potInt198       kInt198;
      potAlias198     kAli198;
      potSelf198      kSelf198;
      Kiln198::potSt198 kScoped198;        // § 11's SCOPED spelling (must stay)
      pkgSt198        kPkg198;             // CONTROL
      kSt198.slip198 = 0;
      kEn198 = GREEN198;
      kUn198.muffle198 = 0;
      kStr198 = "x";
      kVec198 = 8'h0;
      kInt198 = 0;
      kAli198.glaze198 = 0;
      kSelf198 = null;
      kPkg198.glaze198 = 0;
    end
  endfunction
endpackage
package wheel198;
  import kiln198::*;
  class Wheel198;
    function void spin198();
      Kiln198 pot198;
      pot198 = null;
    endfunction
  endclass
endpackage

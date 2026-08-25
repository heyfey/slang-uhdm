// r10v140 arm P — typedef KINDS x alias depth, one package, one class.
// enum / packed struct / packed union / vector, each with a base and an
// alias-of-typedef; a 2-deep chain; a SECOND alias of one base.
// Faces: class property, class-scope local, method formal, method return.
package Quarry_pkg;
  typedef enum bit [2:0] { GRANITE = 1, BASALT = 2, SLATE = 4 } stoneFace;
  typedef stoneFace StoneFace_e;
  typedef StoneFace_e stone_face_chain;
  typedef stoneFace slabKind;

  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } quarryWord;
  typedef quarryWord QuarryWord_s;
  typedef QuarryWord_s quarry_word_chain;

  typedef union packed { bit [7:0] raw; bit [7:0] cooked; } quarryCell;
  typedef quarryCell QuarryCell_u;

  typedef logic [11:0] quarryBits;
  typedef quarryBits QuarryBits_v;

  class Ledger;
    StoneFace_e propFace;
    quarryWord  propWordBase;
    function StoneFace_e readAliasFace(); StoneFace_e lv; lv = propFace; return lv; endfunction
    function stoneFace readBaseFace(); return propFace; endfunction
    function stone_face_chain readChainFace(); return propFace; endfunction
    function slabKind readSlabFace(); return propFace; endfunction
    function QuarryWord_s readAliasWord(); QuarryWord_s lw; return lw; endfunction
    function quarryWord readBaseWord(); return propWordBase; endfunction
    function quarry_word_chain readChainWord(); QuarryWord_s cw; return cw; endfunction
    function QuarryCell_u readAliasCell(); QuarryCell_u lc; return lc; endfunction
    function quarryCell readBaseCell(); quarryCell bc; return bc; endfunction
    function QuarryBits_v readAliasBits(); QuarryBits_v lb; return lb; endfunction
    function quarryBits readBaseBits(); quarryBits bb; return bb; endfunction
    function void takeAliasFace(StoneFace_e f); propFace = f; endfunction
    function void takeBaseFace(stoneFace f); propFace = f; endfunction
    task chewSlab(input slabKind s, output QuarryWord_s w); w = '0; endtask
  endclass

  function StoneFace_e pkgAliasFace(); return GRANITE; endfunction
  function stoneFace pkgBaseFace(); return BASALT; endfunction
  function QuarryWord_s pkgAliasWord(); QuarryWord_s v; return v; endfunction
endpackage

module quarry_top;
  Quarry_pkg::Ledger led;
  Quarry_pkg::StoneFace_e topFace;
  initial topFace = Quarry_pkg::pkgAliasFace();
endmodule

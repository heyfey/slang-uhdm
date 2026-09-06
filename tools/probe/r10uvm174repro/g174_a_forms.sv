// r10uvm174 arm A — THE ARGUMENT KINDS x THE THREE PACKAGE HOMES.
// Golden = Surelog.  The law under test is a DEF/ELAB LISTING split, so this
// arm is compiled in BOTH views.  Names are deliberately unrelated to the arm
// letter and to each other (an a_t/b_t/c_t grid is self-confirming).
package quartzPkg;
  typedef logic [11:0] dozenWord;
  parameter int GLAZE = 5;

  class Prism;
    typedef logic [6:0] shardKind;
    bit [17:0] facet;
    localparam int SHEEN = 9;

    function int inBlockQuery(int unsigned lam);
      int scratch;
      scratch = 0;
      return $bits(byte) + $bits(int) + $bits(shortint) + $bits(longint)
           + $bits(dozenWord) + $bits(shardKind)
           + $bits(facet) + $bits(scratch) + $bits(lam) + $bits(SHEEN)
           + $bits(GLAZE) + $bits(lam + 1);
    endfunction

    extern function int outBlockQuery(int unsigned lam);
  endclass

  function int Prism::outBlockQuery(int unsigned lam);
    int scratch;
    scratch = 0;
    return $bits(byte) + $bits(int) + $bits(shortint) + $bits(longint)
         + $bits(dozenWord) + $bits(shardKind)
         + $bits(facet) + $bits(scratch) + $bits(lam) + $bits(SHEEN)
         + $bits(GLAZE) + $bits(lam + 1);
  endfunction

  function int freeQuery(int unsigned lam);
    int scratch;
    scratch = 0;
    return $bits(byte) + $bits(int) + $bits(shortint) + $bits(longint)
         + $bits(dozenWord)
         + $bits(scratch) + $bits(lam) + $bits(GLAZE) + $bits(lam + 1);
  endfunction
endpackage

module quartzTop;
  quartzPkg::Prism gemHandle;
  int tallySink;
  initial begin
    gemHandle = new();
    tallySink = gemHandle.inBlockQuery(3) + gemHandle.outBlockQuery(4)
              + quartzPkg::freeQuery(5);
  end
endmodule

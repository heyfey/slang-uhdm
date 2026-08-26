// r10uvm157 grid, arm C — THE COUNT / ORDER / INSTANCE axis.  How MANY entries
// a scope lists, in what ORDER, with variables and statements interleaved
// between the typedefs, and what happens when the SAME module is instantiated
// one, two and three times (the DEF listing is written once, the ELABORATED
// one per instance).  MEASUREMENT ONLY.
package Anvil157;
  parameter int FORGE157 = 4;

  // one, two and three typedefs in ONE package-free-function body, with the
  // declarations and the statements deliberately NOT grouped
  function void hammerOne();
    typedef bit [2:0] hammerSolo157;
    hammerSolo157 soloVal;
    soloVal = 0;
  endfunction

  function void hammerTwo();
    typedef bit [3:0] hammerFirst157;
    hammerFirst157 firstVal;
    typedef logic [4:0] hammerSecond157;   // AFTER another declaration
    hammerSecond157 secondVal;
    firstVal = 0;
    secondVal = 0;
  endfunction

  function void hammerThree();
    int leading;
    typedef bit [5:0] hammerAlpha157;
    typedef int hammerBeta157;
    hammerAlpha157 alphaVal;
    typedef logic [FORGE157-1:0] hammerGamma157;
    hammerBeta157 betaVal;
    hammerGamma157 gammaVal;
    leading = 1;
    alphaVal = 0; betaVal = 0; gammaVal = 0;
  endfunction
endpackage

module Bellows157 #(parameter int WIDTH157 = 3) ();
  // three typedefs in a module `initial`, interleaved with variables and
  // statements, plus a NESTED begin with two more of its own
  initial begin
    int puff;
    typedef bit [WIDTH157-1:0] bellowsWide157;
    typedef byte bellowsMark157;
    bellowsWide157 wideVal;
    bellowsMark157 markVal;
    typedef bit [1:0] bellowsTail157;
    bellowsTail157 tailVal;
    puff = 0;
    wideVal = 0; markVal = 0; tailVal = 0;
    begin
      typedef logic [6:0] bellowsInnerA157;
      typedef bit   [7:0] bellowsInnerB157;
      bellowsInnerA157 innerAVal;
      bellowsInnerB157 innerBVal;
      innerAVal = 0; innerBVal = 0;
    end
  end
  // a fork with TWO arms, each with its own typedef
  initial fork
    begin
      typedef bit [8:0] bellowsForkLeft157;
      bellowsForkLeft157 forkLeftVal;
      forkLeftVal = 0;
    end
    begin
      typedef bit [9:0] bellowsForkRight157;
      bellowsForkRight157 forkRightVal;
      forkRightVal = 0;
    end
  join_none
endmodule

module Smithy157;
  // ONE, TWO and THREE instances of the same parameterised module: the DEF
  // listing is written once and each ELABORATED instance carries its own copy
  Bellows157 #(.WIDTH157(3)) solo ();
  Bellows157 #(.WIDTH157(5)) pairA ();
  Bellows157 #(.WIDTH157(5)) pairB ();
  Bellows157 #(.WIDTH157(9)) trioA ();
  Bellows157 #(.WIDTH157(9)) trioB ();
  Bellows157 #(.WIDTH157(9)) trioC ();
  initial begin
    typedef bit [10:0] smithyTop157;
    smithyTop157 topVal;
    topVal = 0;
    Anvil157::hammerOne();
    Anvil157::hammerTwo();
    Anvil157::hammerThree();
  end
endmodule

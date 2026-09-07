// r10v189 arm T — LISTING TOPOLOGY: home+clone in one package, TRANSITIVE
// wildcard import, EXPLICIT import of a class method's home, a MODULE wildcard
// import, and an IN-BODY class method carried into every clone listing.
package AlphaT189v;
  class IdxT189v;
    int a1T189v;
  endclass
  class RootT189v;
    extern function void rootOobT189v();
    function void rootInbT189v();
      bit inbT189v[IdxT189v];
      inbT189v[null] = 1'b1;
    endfunction
  endclass
  function void RootT189v::rootOobT189v();
    bit rootLocT189v[IdxT189v];
    rootLocT189v[null] = 1'b1;
  endfunction
  function void alphaFreeT189v();
    bit alphaFreeLocT189v[IdxT189v];
    alphaFreeLocT189v[null] = 1'b1;
  endfunction
endpackage

// BravoT189v both IMPORTS AlphaT189v (so it carries clones) and owns its own
// out-of-body method (so the same listing carries a HOME entry too).
package BravoT189v;
  import AlphaT189v::*;
  class MidT189v;
    extern function void midOobT189v();
  endclass
  function void MidT189v::midOobT189v();
    bit midLocT189v[IdxT189v];
    midLocT189v[null] = 1'b1;
  endfunction
  function void bravoFreeT189v();
    bit bravoFreeLocT189v[IdxT189v];
    bravoFreeLocT189v[null] = 1'b1;
  endfunction
endpackage

// TRANSITIVE: CharlieT189v imports BravoT189v only.
package CharlieT189v;
  import BravoT189v::*;
  function void charlieUseT189v();
    MidT189v mT189v;
    mT189v = new();
    mT189v.midOobT189v();
    bravoFreeT189v();
  endfunction
endpackage

// EXPLICIT import of the FREE function only.
package DeltaT189v;
  import AlphaT189v::alphaFreeT189v;
  function void deltaUseT189v();
    alphaFreeT189v();
  endfunction
endpackage

module topAlphaT189v;
  import AlphaT189v::*;          // a MODULE wildcard import of the home package
  import CharlieT189v::*;
  import DeltaT189v::*;
  initial begin
    RootT189v rT189v;
    rT189v = new();
    rT189v.rootOobT189v();
    rT189v.rootInbT189v();
    charlieUseT189v();
    deltaUseT189v();
  end
endmodule

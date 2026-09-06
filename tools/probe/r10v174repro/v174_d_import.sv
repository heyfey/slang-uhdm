// r10v174repro arm D — THE FENCE, three import spellings.
// A wildcard-import clone is a copy of the HOME package's ELABORATED object
// and keeps its fold in BOTH of the importer's views, so `!pkgImportCloneEmit
// && !importCloneEmit` must hold the gate shut on all three of these.
package anvilPkg;
  typedef logic [5:0] tongsWord;
  class Bellows;
    logic [21:0] cinder;
    extern function int forgeOut();
  endclass
  function int Bellows::forgeOut();
    forgeOut = $bits(byte) + $bits(int) + $bits(tongsWord) + $bits(cinder);
  endfunction
  function automatic int freeForge();
    freeForge = $bits(byte) + $bits(tongsWord);
  endfunction
endpackage

// (1) WILDCARD import.
package slagPkg;
  import anvilPkg::*;
endpackage

// (2) EXPLICIT single-item imports.
package cinderPkg;
  import anvilPkg::Bellows;
  import anvilPkg::freeForge;
endpackage

// (3) An importer that ALSO has its own out-of-body class method, so one
// package's DEF listing carries both a clone the gate must open and clones the
// fence must hold shut.
package quenchPkg;
  import anvilPkg::*;
  typedef logic [3:0] slackWord;
  class Tuyere;
    logic [19:0] clinker;
    extern function int blastOut();
  endclass
  function int Tuyere::blastOut();
    blastOut = $bits(byte) + $bits(slackWord) + $bits(clinker) + $bits(int);
  endfunction
endpackage

module anvilTop;
  import slagPkg::*;
  anvilPkg::Bellows bl = new();
  quenchPkg::Tuyere ty = new();
  int r;
  initial r = bl.forgeOut() + ty.blastOut() + anvilPkg::freeForge();
endmodule

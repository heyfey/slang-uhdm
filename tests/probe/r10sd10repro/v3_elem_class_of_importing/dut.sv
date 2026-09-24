// VERIFIER CELL v3: two source packages — the array lives in pc, its ELEMENT
// class lives in pd, and pc imports pd.  The element typespec's stamp can then
// name a package that is neither the source of the copy nor the importer.
package pd;
  class kd;
    int xd;
  endclass
endpackage
package pc;
  import pd::*;
  kd mc [string];
endpackage
package qc;
  import pc::*;
  class cc;
    int ownc;
  endclass
endpackage
module topc;
  qc::cc hc;
endmodule

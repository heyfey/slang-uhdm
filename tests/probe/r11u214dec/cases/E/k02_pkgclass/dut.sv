// § importVarElemOwnName214 — the same array inherited by a class of an importing package (svaunit_pkg::svaunit_sequencer's shape)
package p;
  class seed_map; int s; endclass
  seed_map lookup [string];
  int plain_arr [4];
endpackage
package q;
  import p::*;
  class seqr;
    int y;
  endclass
endpackage

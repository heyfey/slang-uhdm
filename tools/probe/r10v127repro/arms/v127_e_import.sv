// r10v127 VERIFIER grid E — IMPORT SHAPES beyond the wildcard: an EXPLICIT
// item import, a CHAINED import (A -> B -> C), an import into a MODULE (not a
// package), and TWO importers of the same home.  MEASUREMENT ONLY.
package Alkanet;
  import "DPI-C" function int akJoin(string lead, int span);
  function automatic int akFree(string lead, int span);
    return akJoin(lead, span);
  endfunction
  class Belfry;
    extern function int akOob(string lead, int span);
  endclass
  function int Belfry::akOob(string lead, int span);
    return akJoin(lead, span);
  endfunction
endpackage

// EXPLICIT single-item import
package Coppice;
  import Alkanet::akFree;
  int cpSeed = 1;
endpackage

// WILDCARD import (the shape the pass models)
package Dovecot;
  import Alkanet::*;
  int dcSeed = 2;
endpackage

// CHAINED: imports the importer
package Elmwood;
  import Dovecot::*;
  int ewSeed = 3;
endpackage

// a SECOND wildcard importer of the same home
package Furrow;
  import Alkanet::*;
  int fwSeed = 4;
endpackage

module Alkanet_top;
  import Alkanet::*;
  import Coppice::*;
  import Dovecot::*;
  import Elmwood::*;
  import Furrow::*;
  Belfry bf;
  int got;
  initial begin
    bf = new();
    got = akFree("m", 5) + bf.akOob("n", 6);
  end
endmodule

// an import into a MODULE, not a package
module Grange_mod;
  import Alkanet::*;
  int got;
  initial got = akFree("g", 7);
endmodule

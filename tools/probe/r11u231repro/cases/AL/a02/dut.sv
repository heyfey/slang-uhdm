// § tfArgAliasDefListFollowsElab231 — the UVM file layout: typedefs in one header, the class and its definitions in another
package p;
`include "glob.svh"
`include "seqb.svh"
endpackage
package q;
  import p::*;
  class qc;
    int x;
  endclass
endpackage
module top;
endmodule

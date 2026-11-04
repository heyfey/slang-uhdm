// § cloneMembEnumAtHomeListing265 (fresh: one header included into two home packages, each imported by its own importer)
package p;
  `include "defs.svh"
endpackage
package p2;
  `include "defs.svh"
endpackage
package q;
  import p::*;
endpackage
package q2;
  import p2::*;
endpackage
module top;
  import p::*;
endmodule

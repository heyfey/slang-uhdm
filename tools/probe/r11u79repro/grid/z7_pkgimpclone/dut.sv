// r11u79 z7 — DOES THE PACKAGE-SIDE IMPORT CLONE CARRY THE HOME PACKAGE'S
// NETS?  `emitPackage`'s `impVars9` walks the imported package's VARIABLE
// members and clones each into the importing package's listing at the import
// statement's slot (§ collectImportedPkgVars' package-side sibling, measured
// on Surelog in r10uvm3).  Surelog builds that listing from
// `CompileHelper::importPackage`, which pushes the home package's WHOLE signal
// vector into the importing scope's `getSignals()` (CompileHelper.cpp:183-190)
// — the same two data arms the module hoist rides.  If the package side rides
// it too, a home package NET is cloned as well; if it does not, LAW A must not
// widen to the clone.  This arm asks golden, wildcard and explicit, direct and
// transitive.
package pa;
  wire  [7:0] a_net;
  logic [7:0] a_var = 8'd1;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sa_t;
  sa_t        a_struct;
  logic [7:0] a_uarr [0:1];
endpackage

package pb;
  import pa::*;               // WILDCARD, direct
  wire  [7:0] b_net;
  logic [7:0] b_var = 8'd2;
endpackage

package pc;
  import pb::*;               // TRANSITIVE: pc -> pb -> pa
  wire  [7:0] c_net;
endpackage

package pe;
  import pa::a_net;           // an EXPLICIT import of a NET
  import pa::a_var;
  wire  [7:0] e_net;
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  import pe::*;
  assign o = {24'd0, c_net} ^ {24'd0, e_net};
endmodule

// r10earl87 arm g1 — THE CORE GRID for the materialized-import vpiOverriden
// stamp.  Surelog's NetlistElaboration::elab_parameters_ stamps every
// param_assign it materializes with `instance->isOverridenParam(paramName)`,
// and `m_overridenParams` is a NAME SET (ModuleInstance.cpp:388-395).  A
// WILDCARD-IMPORTED package member therefore inherits the stamp of a
// same-named FORMAL that this instantiation overrode.
//
// rows: pk1 exports PA PB PC PD; `leaf` declares its own PA (overridden at
// u_ov), PB (never overridden) and PE (no package twin).
package pk1;
  localparam int PA = 11;
  localparam int PB = 12;
  localparam int PC = 13;
  parameter  int PD = 14;
endpackage

module leaf #(
  parameter int PA = 1,
  parameter int PB = 2,
  parameter int PE = 3
) (output logic [7:0] o);
  import pk1::*;
  assign o = PA[7:0] + PB[7:0] + PE[7:0] + PC[7:0] + PD[7:0];
endmodule

module top87 (output logic [7:0] o1, o2, o3);
  // u_ov  : PA overridden      -> imported PA copy must inherit the stamp
  leaf #(.PA(7))          u_ov  (.o(o1));
  // u_two : PA and PB overridden
  leaf #(.PA(7), .PB(8))  u_two (.o(o2));
  // u_no  : nothing overridden -> no stamp anywhere
  leaf                    u_no  (.o(o3));
endmodule

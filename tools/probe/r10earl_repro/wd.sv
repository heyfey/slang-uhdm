// wd.sv — PASS 14 round 4, the two surviving `ref_typespec '' :0:0` vs <null>
// heads (flash_phy_rd, rstmgr).  BOTH point at a folded constant that is a
// REPLICATION COUNT in a DEF-listing continuous assign:
//   flash_phy_rd.sv:130  `assign alloc = no_match ? {NumBuf{req_i}} & ...`
//   rstmgr.sv:139        `.rst_parent_ni({PowerDomains{1'b1}})`
// The fold itself already matches (§ shadowedImportParamFold substitutes the
// package value); only the constant's ts ref is missing on our side.
// Rows:
//   R1  replication count = a WILDCARD-IMPORTED package parameter  (the head)
//   R2  replication count = the module's OWN localparam            (control)
//   R3  the same package parameter read OUTSIDE a replication      (control)
//   R4  the package parameter as a PORT-CONNECTION replication count
//       (the rstmgr shape — inside an instance's actual, not a cont_assign)
package wdp;
  parameter int NB = 4;
  parameter int PD = 2;
endpackage

module wdsub #(
  parameter int W = 1
) (
  input logic [W-1:0] par_ni
);
endmodule

module wdnp import wdp::*; (
  input logic req_i,
  output logic [NB-1:0] alloc_o,
  output logic [7:0]    plain_o
);
  localparam int ML = 3;
  logic [NB-1:0] buf_alloc;
  logic [ML-1:0] loc_alloc;

  // R1 — the head shape.
  assign alloc_o = {NB{req_i}} & buf_alloc;
  // R2 — module localparam count (control).
  assign plain_o = {5'b0, {ML{req_i}} & loc_alloc};
  // R3 — a plain package-parameter read, no replication (control).
  wire [7:0] w3 = NB + 8'h1;

  // R4 — the rstmgr shape: a replication in a PORT CONNECTION actual.
  wdsub #(.W(PD)) u_sub (.par_ni({PD{1'b1}}));

  // R5 — a cont_assign fold under a PLAIN binary operation (is the rule "any
  // operation under a def cont_assign", or only the replication COUNT?).
  logic [7:0] p5;
  assign p5 = NB + 8'h1;
  // R6 — the replication DIRECTLY under the cont_assign, no `&` above it.
  logic [3:0] p6;
  assign p6 = {NB{req_i}};
endmodule

module wdtop;
  logic r;
  logic [3:0] a;
  logic [7:0] p;
  wdnp u0(.req_i(r), .alloc_o(a), .plain_o(p));
endmodule

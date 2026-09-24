// r11u77 y1 — LAW A: THE PACKAGE NET, KIND BY KIND, AND ITS BINDING REACH.
// `collectImportedPkgVars` walks the package's VARIABLE members only, so a
// package NET is absent from both the def-view listing and the elab-view
// hoist (r11u75 residue 1, `g2_importshapes` `w_net`).  Surelog's
// `importPackage` copies the package's SIGNAL VECTOR wholesale
// (CompileHelper.cpp:183-190), and `NetlistElaboration::elabSignal` then
// decides the object's kind per signal.  This arm asks WHICH kinds golden
// writes for a package net and WHICH of them a gen-scope namesake binds.
package pn;
  wire  [31:0] n_plain;
  wire         n_scalar;
  tri   [31:0] n_tri;
  wand  [31:0] n_wand;
  supply0      n_sup0;
  wire  [7:0]  n_arr [0:1];     // an UNPACKED-ARRAY net -> array_net?
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sn_t;
  wire  sn_t   n_wstruct;       // a STRUCT-typed net
  typedef enum logic [1:0] { EA, EB } en_t;
  wire  en_t   n_wenum;         // an ENUM-typed net
endpackage

module dut (output logic [31:0] o);
  import pn::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gn
    logic [31:0] n_plain;   assign n_plain   = 32'd1;
    logic [31:0] n_scalar;  assign n_scalar  = 32'd2;
    logic [31:0] n_tri;     assign n_tri     = 32'd3;
    logic [31:0] n_wand;    assign n_wand    = 32'd4;
    logic [31:0] n_sup0;    assign n_sup0    = 32'd5;
    logic [31:0] n_arr;     assign n_arr     = 32'd6;
    logic [31:0] n_wstruct; assign n_wstruct = 32'd7;
    logic [31:0] n_wenum;   assign n_wenum   = 32'd8;
  end
  assign o = gn[0].n_plain ^ gn[0].n_scalar ^ gn[0].n_tri ^ gn[0].n_wand
           ^ gn[0].n_sup0  ^ gn[0].n_arr    ^ gn[0].n_wstruct ^ gn[0].n_wenum;
endmodule

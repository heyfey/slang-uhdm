// r11u77 y3 — LAW A's IMPORT SHAPES, AND THE BOUNDARIES THAT KEEP IT HONEST.
// GOLDEN WRITES NOTHING ON A MISS: a package nobody imports and a $unit name
// hold no holder (g2's own cells).  This arm asks the NET through every
// import shape the hoist already models for a variable: wildcard, explicit,
// the TRANSITIVE hop (§ transitiveImportRidesTheHoist217), TWO import copies
// (a file-level import plus a module-level one), and the two negatives.
package pa;
  wire  [31:0] a_net;
  logic [15:0] a_var;
endpackage

package pb;                 // the TRANSITIVE hop: pb imports pa
  import pa::*;
  wire  [31:0] b_net;
endpackage

package pc;
  wire  [31:0] c_net;       // EXPLICIT import of a NET
  wire  [31:0] c_unread;    // explicitly NOT named by the import item
endpackage

package pz;
  wire  [31:0] z_net;       // NOBODY imports pz
endpackage

wire [31:0] unitnet;        // a $unit-scope NET

import pa::*;               // a FILE-level import: the copy rides TWICE

module dut (output logic [31:0] o);
  import pa::*;
  import pb::*;
  import pc::c_net;
  for (genvar i = 0; i < 1; i = i + 1) begin : gi
    logic [31:0] a_net;   assign a_net   = 32'd1;
    logic [31:0] a_var;   assign a_var   = 32'd2;
    logic [31:0] b_net;   assign b_net   = 32'd3;
    logic [31:0] c_net;   assign c_net   = 32'd4;
    logic [31:0] c_unread; assign c_unread = 32'd5;
    logic [31:0] z_net;   assign z_net   = 32'd6;
    logic [31:0] unitnet; assign unitnet = 32'd7;
  end
  assign o = gi[0].a_net ^ gi[0].a_var ^ gi[0].b_net ^ gi[0].c_net
           ^ gi[0].c_unread ^ gi[0].z_net ^ gi[0].unitnet;
endmodule

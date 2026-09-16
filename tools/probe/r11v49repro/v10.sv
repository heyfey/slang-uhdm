// v11u49 arm v10 — PACKED control for v6b: a PACKED struct package localparam
// member-selected from an IMPORTING package's parameter declaration.
// Reachable on the PRISTINE binary (a select in a package parameter decl).
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t PIMP = '{CTL:8'd3, DAT:8'd4};
endpackage
package p2;
  import p::PIMP;
  localparam int USE = PIMP.DAT;
endpackage
module v10 import p::*; import p2::USE; (output logic [31:0] o);
  assign o = PIMP.CTL + USE;
endmodule

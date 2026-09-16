// v11u49 arm v8 — LAW B name COLLISION across packages, unconfounded:
// NO scoped `pkg::NAME` read anywhere (both modules wildcard-import).
// q::CFG is member-selected in q's FUNCTION BODY; p::CFG is NEVER selected.
// Both parameters are spelled CFG, and hasMemberSelectOf is keyed on the NAME.
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t CFG = '{CTL:8'd1, DAT:8'd2};
  localparam pb_t OTH = '{CTL:8'd3, DAT:8'd4};
endpackage
package q;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } qb_t;
  localparam qb_t CFG = '{CTL:8'd5, DAT:8'd6};
  function automatic int g(); return CFG.DAT; endfunction
endpackage
module v8 import p::*; import q::g; (output logic [31:0] o);
  assign o = CFG.CTL + OTH.CTL + g();
endmodule

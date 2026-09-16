// v11u49 arm v3 — LAW B name-collision: two packages, same parameter name.
// q::CFG is selected in q's FUNCTION BODY (never in a parameter decl);
// p::CFG is never selected at all.  Pristine counts neither.
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
module v3 (output logic [31:0] o);
  assign o = p::CFG.CTL + p::OTH.CTL + q::g();
endmodule

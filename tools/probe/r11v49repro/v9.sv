// v11u49 arm v9 — PRE-EXISTING CONTROL for the name-collision class:
// q::CFG selected in q's PARAMETER DECLARATION (counted by PRISTINE too);
// p::CFG never selected; no scoped pkg::NAME read anywhere.
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t CFG = '{CTL:8'd1, DAT:8'd2};
  localparam pb_t OTH = '{CTL:8'd3, DAT:8'd4};
endpackage
package q;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } qb_t;
  localparam qb_t CFG = '{CTL:8'd5, DAT:8'd6};
  localparam int  USE = CFG.DAT;
endpackage
module v9 import p::*; import q::USE; (output logic [31:0] o);
  assign o = CFG.CTL + OTH.CTL + USE;
endmodule

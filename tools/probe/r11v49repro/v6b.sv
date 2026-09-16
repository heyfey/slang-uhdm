// v11u49 arm v6b — LAW A: an UNPACKED struct package `parameter` (not localparam),
// and the same parameter MATERIALIZED into an importing package.
package p;
  typedef struct { logic [7:0] CTL; logic [7:0] DAT; } ub_t;
  parameter  ub_t UPRM = '{CTL:8'd1, DAT:8'd2};
  localparam ub_t UIMP = '{CTL:8'd3, DAT:8'd4};
endpackage
package p2;
  import p::UIMP;
  localparam int USE = UIMP.DAT;
endpackage
module v6b (output logic [31:0] o);
  assign o = p::UPRM.DAT + p2::USE;
endmodule

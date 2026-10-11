// § elabCastKeyBindsDefNet286 — a key whose value reads a parameter overridden per instance
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module leaf import q::*; #(parameter logic [3:0] P = 4'd1) (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: P, b: 4'd2};
  assign o = A;
endmodule
module top (output logic [7:0] o1, output logic [7:0] o2);
  leaf #(.P(4'd3)) u1(.o(o1));
  leaf u2(.o(o2));
endmodule

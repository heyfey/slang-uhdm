// § elabCastKeyBindsDefNet286 — a pattern in the top module and in its child (top keeps its own wire)
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module m11a import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
module top import q::*; (output logic [7:0] o, output logic [7:0] o2);
  localparam p2_t B = p2_t'{a: 4'd3, b: 4'd4};
  m11a u(.o(o2));
  assign o = B;
endmodule

// § elabCastKeyBindsDefNet286 — two cast patterns sharing keys in one definition, reversed key order
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module leaf import q::*; (output logic [7:0] o, output logic [7:0] o2);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  localparam p2_t B = p2_t'{b: 4'd3, a: 4'd4};
  assign o = A;
  assign o2 = B;
endmodule
module top (output logic [7:0] o1, output logic [7:0] o2);
  leaf l(.o(o1), .o2(o2));
endmodule

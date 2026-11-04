// § elabCastKeyBindsDefNet286 — instance depth 3
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module leaf import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
module mid2 (output logic [7:0] o); leaf l(.o(o)); endmodule
module mid (output logic [7:0] o); mid2 n(.o(o)); endmodule
module top (output logic [7:0] o1); mid m(.o(o1)); endmodule

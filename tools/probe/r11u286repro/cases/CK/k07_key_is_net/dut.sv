// § elabCastKeyBindsDefNet286 — a key that names a declared signal of the definition
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module leaf import q::*; (output logic [7:0] o);
  logic [3:0] a;
  assign a = 4'h1;
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
module top (output logic [7:0] o1);
  leaf l(.o(o1));
endmodule

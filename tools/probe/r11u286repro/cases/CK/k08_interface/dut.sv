// § elabCastKeyBindsDefNet286 — a cast pattern in an interface body and in a program-free module (interface control)
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
interface ifc import q::*; ();
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  logic [7:0] o;
  assign o = A;
endinterface
module top (output logic [7:0] o1);
  ifc i1 ();
  ifc i2 ();
  assign o1 = i1.o;
endmodule

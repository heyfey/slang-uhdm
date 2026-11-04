// § ndaLeftmostLeafElab139
// case nd04: a net declaration assignment whose left operand is a struct member of a port
package np2; typedef struct packed { logic f; logic g; } s_t; endpackage
module top(input np2::s_t s, input logic b, output logic y);
  wire w = s.f ^ b;
  assign y = w;
endmodule

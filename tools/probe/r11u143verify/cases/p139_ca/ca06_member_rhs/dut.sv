// § caLhsDefNetUnlessOpRhs139
// case ca06: a struct-member right-hand side
package cp6; typedef struct packed { logic f; logic g; } s_t; endpackage
module top(input cp6::s_t s, output logic y);
  assign y = s.g;
endmodule

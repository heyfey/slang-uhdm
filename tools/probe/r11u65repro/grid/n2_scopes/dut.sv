// r11u65 n2 — WHERE THE TYPEDEF LIVES and HOW IT IS WRITTEN.  The c2 arm
// already measures the explicitly `pk::`-qualified form (golden 0, ours 0).
// This arm adds the WILDCARD-IMPORTED and EXPLICITLY-IMPORTED unqualified
// forms, which § unqualDimNet9 and § ifaceDefArrayNetIsAnyUnpackedDim225 both
// say behave like a LOCAL typedef on the packed road.
package pk65;
  parameter int unsigned N = 2;
  parameter int unsigned D = 4;
  typedef logic [N-1:0] pa_t [D];   // unpacked-array typedef in a PACKAGE
  typedef logic [N-1:0] pv_t;       // plain packed typedef in a PACKAGE
endpackage

module wild (output logic [1:0] o);
  import pk65::*;                   // WILDCARD import, unqualified use
  pa_t w1;
  pv_t w2;
  assign o = w1[0] | w2;
endmodule

module expl (output logic [1:0] o);
  import pk65::pa_t;                // EXPLICIT import, unqualified use
  import pk65::pv_t;
  pa_t e1;
  pv_t e2;
  assign o = e1[0] | e2;
endmodule

module scoped (output logic [1:0] o);
  pk65::pa_t s1;                    // EXPLICITLY QUALIFIED (the c2 control)
  pk65::pv_t s2;
  assign o = s1[0] | s2;
endmodule

module dut (output logic [1:0] o);
  logic [1:0] a, b, c;
  wild   u1 (.o(a));
  expl   u2 (.o(b));
  scoped u3 (.o(c));
  assign o = a | b | c;
endmodule

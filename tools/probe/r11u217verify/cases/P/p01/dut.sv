// § pkgImpParamMemberColons210 — r11u217 p01: a CHAIN of three packages (c imports b imports a), a's struct-pattern parameter re-listed in b and in c, the module importing only c
package a;
  typedef struct packed { logic x; logic [2:0] y; } e_t;
  parameter e_t EA = '{ x: 1'b1, y: 3'd2 };
  typedef logic [3:0] m_t;
  parameter m_t MA = 4'b1001;
endpackage
package b;
  import a::*;
  parameter logic LB = 1'b1;
endpackage
package c;
  import b::*;
  parameter logic LC = 1'b0;
endpackage
module dut import c::*; (output logic o);
  assign o = LC;
endmodule

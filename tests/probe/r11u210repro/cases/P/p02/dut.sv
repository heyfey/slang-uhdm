// § pkgImpParamMemberColons210 — p02: control, the struct-pattern parameters read only through the home package (no importing package)
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  typedef logic [3:0] m_t;
  parameter m_t MON = 4'b0101;
endpackage
module dut import hp::*; (output logic [5:0] o);
  assign o = EA;
endmodule

// § pkgImpParamMemberColons210 — p05: the module imports ONLY the importing package (ip imports hp; ibex_tracer's shape), so hp's parameters reach the module's listing transitively
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
  typedef logic [3:0] m_t;
  parameter m_t MON = 4'b0101;
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module dut import ip::*; (output logic [1:0] o);
  assign o = LOC;
endmodule

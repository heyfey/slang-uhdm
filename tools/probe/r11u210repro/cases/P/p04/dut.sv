// § pkgImpParamAliasColons210 — p04: two vector-typedef parameters and one struct parameter imported by a package, the module reading only the importing package's own parameter
package hp;
  typedef struct packed { logic a; logic [2:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, c: 3'd2 };
  typedef logic [3:0] m_t;
  typedef logic [7:0][1:0] w_t;
  parameter m_t MON = 4'b0011;
  parameter w_t WV = '0;
endpackage
package ip;
  import hp::*;
  parameter int K = 1;
endpackage
module dut import hp::*; import ip::*; (output int o);
  assign o = K;
endmodule

// § pkgTopWidePatReplTsName210 — q03: control, the qualified enum member in a MODULE parameter's pattern (not a package)
package ep;
  typedef enum logic [1:0] { NA, NB, NC } k_e;
  typedef struct packed { k_e K; logic [3:0] N; } s_t;
endpackage
module dut(output logic [1:0] o);
  localparam ep::s_t S = '{ K: ep::NB, N: 4'd2 };
  assign o = S.K;
endmodule

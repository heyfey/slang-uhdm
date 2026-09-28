// § pkgTopWidePatReplTsName210 — q01: control (narrow struct: the elaborated listing is flattened), a package struct-pattern member written as a package-qualified enum constant (narrow struct)
package ep;
  typedef enum logic [1:0] { NA, NB, NC } k_e;
  typedef struct packed { k_e K; logic [3:0] N; } s_t;
endpackage
package vp;
  localparam ep::s_t S = '{ K: ep::NB, N: 4'd3 };
endpackage
module dut(output logic [1:0] o);
  assign o = vp::S.K;
endmodule

// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [3:0] h; logic [3:0] l; } hl_t;
  typedef union packed { hl_t s; logic [7:0] raw; } u_t;
  typedef struct packed { u_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 16'hA55A) (output logic [3:0] o, output logic [7:0] r);
  assign o = P.u.s.h;
  assign r = P.u.raw;
endmodule
module dut(output logic [3:0] o, output logic [7:0] r); kid k0 (.o(o), .r(r)); endmodule

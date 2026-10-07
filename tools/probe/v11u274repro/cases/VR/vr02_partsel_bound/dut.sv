// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h000102) (input logic [15:0] x, output logic [1:0] o, output logic [3:0] q);
  assign o = x[P.u.b +: 2];
  assign q = x[P.u.a[3:0] +: 4];
endmodule
module dut(input logic [15:0] x, output logic [1:0] o, output logic [3:0] q); kid k0 (.x(x), .o(o), .q(q)); endmodule

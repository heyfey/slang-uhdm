// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o); assign o = P.d; endmodule
module dut(output logic [7:0] o, output logic [7:0] o2, output logic [7:0] o3);
  kid k0 (.o(o));
  assign o2 = k0.P.u.a;
  assign o3 = dut.k0.P.u.b;
endmodule

// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter type T = pk::c_t, parameter T P = '0) (output logic [7:0] o); assign o = P.u.a; endmodule
module dut(output logic [7:0] o, output logic [7:0] o2);
  kid k0 (.o(o));
  kid #(.T(pk::c_t), .P(24'h112233)) k1 (.o(o2));
endmodule

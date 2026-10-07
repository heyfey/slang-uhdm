// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module leaf #(parameter pk::c_t P = '0) (output logic [7:0] o); assign o = P.u.a; endmodule
module mid #(parameter pk::c_t Q = '0) (output logic [7:0] o); leaf #(.P(Q)) l (.o(o)); endmodule
module dut(output logic [7:0] o, output logic [7:0] o2);
  mid #(.Q(24'h0f0e0d)) m0 (.o(o));
  mid m1 (.o(o2));
endmodule

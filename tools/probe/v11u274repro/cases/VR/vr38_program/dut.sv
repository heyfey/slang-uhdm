// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
program pg #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o); initial o = P.u.a; endprogram
module dut(output logic [7:0] o); pg p0 (.o(o)); endmodule

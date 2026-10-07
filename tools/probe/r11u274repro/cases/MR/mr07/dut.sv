// § elabMemberReadCopyChain274
typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
typedef struct packed { u_t u; logic [7:0] d; } s_t;
module kid #(parameter s_t P = '0) (output logic [7:0] o);
  always_comb o = P.u.a ^ P.d;
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule

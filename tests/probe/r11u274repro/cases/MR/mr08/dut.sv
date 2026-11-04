// § elabMemberReadCopyChain274
typedef struct packed { logic [3:0] a; logic [3:0] b; } e_t;
typedef struct packed { e_t [1:0] arr; logic [7:0] d; } s_t;
module kid #(parameter s_t P = '0) (output logic [7:0] o);
  always_comb o = P.arr[0].a ^ P.d;
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule

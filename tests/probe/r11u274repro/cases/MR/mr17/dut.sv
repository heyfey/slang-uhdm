// § elabMemberReadCopyChain274
typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
module kid #(parameter s_t P = '{a: 1, b: 2}) (output logic [7:0] o);
  function automatic logic [7:0] f(); return P.a; endfunction
  assign o = f();
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
